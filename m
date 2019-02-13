Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9FBAC282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 16:30:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A2E4222B2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 16:30:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A2E4222B2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=I-love.SAKURA.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CAA3D8E0002; Wed, 13 Feb 2019 11:30:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C34DE8E0001; Wed, 13 Feb 2019 11:30:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AAE158E0002; Wed, 13 Feb 2019 11:30:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 63A388E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 11:30:42 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id h15so2232153pfj.22
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 08:30:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to
         :subject:message-id:date:user-agent:mime-version:content-language
         :content-transfer-encoding;
        bh=hfzoLZ4g7HdmXoFFcTRlnZImEF7uzjeua5wgjN5bqI4=;
        b=FcPwKPLLXeI56pMfEzdbyMzAdq35la9yswLbnGYJw0wnGR1lWJcBe3VmDH1rvlkqLi
         dmOCSignvWAeANYlT4o7qvOqM20u2M3jhnu0hudOSqnuFQ1OXMNS9nR2lU3EA+qofvrw
         DNDn0SYTOrB/2Z0mpkZbTHieeqz8siIPNIxs/qmBKmnEamgj3pc9vYLWDfGoLkcZJBTH
         vDJFwWvFfNSsai2Z/9kpncXaBbs2yocY7Tv6RkSdVCQBEnLVugZhkdGmH5F/Q3rmA+XF
         p/Hmxe/XUe66ta0c4p/AJb3jU73guYaThd68tVBlsVHJA3LkhWt9r/m/hQdNBzGdwsvM
         F29Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AHQUAuakPi8cEVukosqG6/Zh3OSqSG93im+sbYBjjFFSOYCBS2Z7J76s
	2hNNze3kBvSVmPx6Jl0uI2nYLv+sIW5ODOsaprU35WBNo6WCoWZPE1dHYskWNjqfeXh0X0iAI7o
	QSaUX+FGFvVZEnY1Yh2o3HL9ew4TzAJRC+e4zjwXMx1y29stTX6rFOagRY/1AOPYWbg==
X-Received: by 2002:a63:d846:: with SMTP id k6mr1201923pgj.251.1550075441983;
        Wed, 13 Feb 2019 08:30:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia9yHA8+kLFKzGXo6De4ca4sftXoZNs1CWcIXkFntIyjeUZ+LjwCPVnt8XN4CC/bQREN0C+
X-Received: by 2002:a63:d846:: with SMTP id k6mr1201801pgj.251.1550075440417;
        Wed, 13 Feb 2019 08:30:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550075440; cv=none;
        d=google.com; s=arc-20160816;
        b=AjHixWeHbh25aYt5sHm9xTQ4DnqJgqwhqZsZXoVZpPsga+gUzd2lue+VYebThaWMKW
         FHoEsN+8yTQtrGEyonw6uZ7esoq2jlwSgfK2KJN+vGpfTtPSnTc/5C5TAWLpCIW76UPt
         TT8cWqOvJPzQjcJEvtInN1jCOAxBbhXA/LzsyfffS1jtlQl9ZSipyypMiKKtp+sOWW7y
         rJJOF7uIYtqoCt7B38dsRPkavBxhMomPc837Fe+v5j/cKPjjOdeip1kN8nah3XFDWHpB
         VL3st4SzWcxbLtnRha9gK/i8i+2NaAfn+3fMC8qWpZUnl0+hthB7+Mti0OSOIKiazHHp
         pRtQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:mime-version:user-agent
         :date:message-id:subject:to:from;
        bh=hfzoLZ4g7HdmXoFFcTRlnZImEF7uzjeua5wgjN5bqI4=;
        b=vN+54iiHOHKfnAxhGzM6jVnwuY0+OnGWJEVqm/u5ymxP59cF70SoFcj/FQBxXgWW1z
         J5F1mUoQdAWyBL8gUnSze2pYmPu/toJmpRAHmgkA8cD6OwW3hrup02+pFel+2F/ZU/1x
         7jCkQuEXIsJHjVU7vIXvW7IsGjAo4OyRAXONeczjCHIDqZqe2BGN5lhgEIBn1I9OmNBO
         +yJtapkMSMD/qSlUKkHiJHJCwUP+4608ISTrRs55XPE6I7o1PwJ0bRN8mNl504LkRqCI
         9XGyuJQliUvR7S5BENriRnefuNaSnv2miDkwAj+CNHwkUGSPrcExwlHXQ0mQrWfyADrx
         VvzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id l23si15495954pgh.533.2019.02.13.08.30.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 08:30:40 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav110.sakura.ne.jp (fsav110.sakura.ne.jp [27.133.134.237])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x1DGUcnJ008318
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 01:30:38 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav110.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav110.sakura.ne.jp);
 Thu, 14 Feb 2019 01:30:38 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav110.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x1DGUXhQ008277
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 01:30:38 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
To: linux-mm <linux-mm@kvack.org>
Subject: [PATCH v3] mm,page_alloc: wait for oom_lock before retrying.
Message-ID: <20900d89-b06d-2ec6-0ae0-beffc5874f26@I-love.SAKURA.ne.jp>
Date: Thu, 14 Feb 2019 01:30:28 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is resume of https://lkml.kernel.org/r/1500202791-5427-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp .



Reproducer:
----------
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <signal.h>
#include <sys/prctl.h>

int main(int argc, char *argv[])
{
	static int pipe_fd[2] = { EOF, EOF };
	char *buf = NULL;
	unsigned long size = 0;
	unsigned int i;
	int fd;
	char buffer[4096];
	pipe(pipe_fd);
	signal(SIGCLD, SIG_IGN);
	if (fork() == 0) {
		prctl(PR_SET_NAME, (unsigned long) "first-victim", 0, 0, 0);
		while (1)
			pause();
	}
	close(pipe_fd[1]);
	prctl(PR_SET_NAME, (unsigned long) "normal-priority", 0, 0, 0);
	for (i = 0; i < 1024; i++)
		if (fork() == 0) {
			char c;
			/* Wait until the first-victim is OOM-killed. */
			read(pipe_fd[0], &c, 1);
			/* Try to consume CPU time via page fault. */
			memset(buffer, 0, sizeof(buffer));
			_exit(0);
		}
	close(pipe_fd[0]);
	fd = open("/dev/zero", O_RDONLY);
	for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
		char *cp = realloc(buf, size);
		if (!cp) {
			size >>= 1;
			break;
		}
		buf = cp;
	}
	while (size) {
		int ret = read(fd, buf, size); /* Will cause OOM due to overcommit */
		if (ret <= 0)
			break;
		buf += ret;
		size -= ret;
	}
	kill(-1, SIGKILL);
	return 0; /* Not reached. */
}
----------



Before this patch: http://I-love.SAKURA.ne.jp/tmp/serial-20190212.txt.xz
Numbers from grep'ing of SysRq-t part inside the stall:

  $ grep -F 'Call Trace:' serial-20190212.txt | wc -l
  1234
  $ grep -F 'locks held by' serial-20190212.txt | wc -l
  1046
  $ grep -F '__alloc_pages_nodemask' serial-20190212.txt | wc -l
  1046
  $ grep -F '__alloc_pages_slowpath+0x16f8/0x2350' serial-20190212.txt | wc -l
  946

90% of allocating threads are sleeping at

        /*
         * Acquire the oom lock.  If that fails, somebody else is
         * making progress for us.
         */
        if (!mutex_trylock(&oom_lock)) {
                *did_some_progress = 1;
                schedule_timeout_uninterruptible(1);
                return NULL;
        }

and almost all of them are simply waiting for CPU time (indicated by a
'locks held by' line without lock information due to TASK_RUNNING state).
That is, many hundreds of allocating threads are ready to hold
the owner of oom_lock preempted.

[  504.760909] normal-priority invoked oom-killer: gfp_mask=0x6280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), order=0, oom_score_adj=0
[  513.650210] CPU: 0 PID: 17881 Comm: normal-priority Kdump: loaded Not tainted 5.0.0-rc6 #826
[  513.653799] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 04/13/2018
[  513.657968] Call Trace:
[  513.660026]  dump_stack+0x86/0xca
[  513.662292]  dump_header+0x10a/0x9d0
[  513.664673]  ? _raw_spin_unlock_irqrestore+0x3d/0x60
[  513.667319]  ? ___ratelimit+0x1d1/0x3c5
[  513.669682]  oom_kill_process.cold.32+0xb/0x5b9
[  513.672218]  ? check_flags.part.40+0x420/0x420
[  513.675347]  ? rcu_read_unlock_special+0x87/0x100
[  513.678734]  out_of_memory+0x287/0x7f0
[  513.681146]  ? oom_killer_disable+0x1f0/0x1f0
[  513.683629]  ? mutex_trylock+0x191/0x1e0
[  513.685983]  ? __alloc_pages_slowpath+0xa03/0x2350
[  513.688692]  __alloc_pages_slowpath+0x1cdf/0x2350
[  513.692541]  ? release_pages+0x8d6/0x12d0
[  513.696140]  ? warn_alloc+0x120/0x120
[  513.699669]  ? __lock_is_held+0xbc/0x140
[  513.703204]  ? __might_sleep+0x95/0x190
[  513.706554]  __alloc_pages_nodemask+0x510/0x5f0

[  717.991658] normal-priority R  running task    23432 17881   9439 0x80000080
[  717.994203] Call Trace:
[  717.995530]  __schedule+0x69a/0x1890
[  717.997116]  ? pci_mmcfg_check_reserved+0x120/0x120
[  717.999020]  ? __this_cpu_preempt_check+0x13/0x20
[  718.001299]  ? lockdep_hardirqs_on+0x347/0x5a0
[  718.003175]  ? preempt_schedule_irq+0x35/0x80
[  718.004966]  ? trace_hardirqs_on+0x28/0x170
[  718.006704]  preempt_schedule_irq+0x40/0x80
[  718.008440]  retint_kernel+0x1b/0x2d
[  718.010167] RIP: 0010:dump_stack+0xbc/0xca
[  718.011880] Code: c7 c0 ed 66 96 e8 7e d5 e2 fe c7 05 34 bc ed 00 ff ff ff ff 0f ba e3 09 72 09 53 9d e8 87 03 c4 fe eb 07 e8 10 02 c4 fe 53 9d <5b> 41 5c 41 5d 5d c3 90 90 90 90 90 90 90 55 48 89 e5 41 57 49 89
[  718.018262] RSP: 0000:ffff888111a672e0 EFLAGS: 00000286 ORIG_RAX: ffffffffffffff13
[  718.020947] RAX: 0000000000000007 RBX: 0000000000000286 RCX: 1ffff1101563db64
[  718.023530] RDX: 0000000000000000 RSI: ffffffff95c6ff40 RDI: ffff8880ab1edab4
[  718.026597] RBP: ffff888111a672f8 R08: ffff8880ab1edab8 R09: 0000000000000006
[  718.029478] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
[  718.032224] R13: 00000000ffffffff R14: ffff888111a67628 R15: ffff888111a67628
[  718.035339]  dump_header+0x10a/0x9d0
[  718.037231]  ? _raw_spin_unlock_irqrestore+0x3d/0x60
[  718.039349]  ? ___ratelimit+0x1d1/0x3c5
[  718.041380]  oom_kill_process.cold.32+0xb/0x5b9
[  718.043451]  ? check_flags.part.40+0x420/0x420
[  718.045418]  ? rcu_read_unlock_special+0x87/0x100
[  718.047453]  out_of_memory+0x287/0x7f0
[  718.049245]  ? oom_killer_disable+0x1f0/0x1f0
[  718.051527]  ? mutex_trylock+0x191/0x1e0
[  718.053398]  ? __alloc_pages_slowpath+0xa03/0x2350
[  718.055478]  __alloc_pages_slowpath+0x1cdf/0x2350
[  718.057978]  ? release_pages+0x8d6/0x12d0
[  718.060245]  ? warn_alloc+0x120/0x120
[  718.062836]  ? __lock_is_held+0xbc/0x140
[  718.065815]  ? __might_sleep+0x95/0x190
[  718.068060]  __alloc_pages_nodemask+0x510/0x5f0



After this patch: http://I-love.SAKURA.ne.jp/tmp/serial-20190212-2.txt.xz
The OOM killer is smoothly invoked, though the system after all got stuck
due to a different problem.



While this patch cannot avoid delays caused by unlimited concurrent direct
reclaim, let's stop telling the lie

        /*
         * Acquire the oom lock.  If that fails, somebody else is
         * making progress for us.
         */

because many of allocating threads are preventing the owner of oom_lock from
making progress. Therefore, here again is a patch.



From 63c5c8ee7910fa9ef1c4067f1cb35a779e9d582c Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Tue, 12 Feb 2019 20:12:35 +0900
Subject: [PATCH v3] mm,page_alloc: wait for oom_lock before retrying.

When many hundreds of threads concurrently triggered a page fault, and
one of them invoked the global OOM killer, the owner of oom_lock is
preempted for minutes because they are rather depriving the owner of
oom_lock of CPU time rather than waiting for the owner of oom_lock to
make progress. We don't want to disable preemption while holding oom_lock
but we want the owner of oom_lock to complete as soon as possible.

Thus, this patch kills the dangerous assumption that sleeping for one
jiffy is sufficient for allowing the owner of oom_lock to make progress.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/page_alloc.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 35fdde0..c867513 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3618,7 +3618,10 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 	 */
 	if (!mutex_trylock(&oom_lock)) {
 		*did_some_progress = 1;
-		schedule_timeout_uninterruptible(1);
+		if (mutex_lock_killable(&oom_lock) == 0)
+			mutex_unlock(&oom_lock);
+		else if (!tsk_is_oom_victim(current))
+			schedule_timeout_uninterruptible(1);
 		return NULL;
 	}
 
-- 
1.8.3.1

