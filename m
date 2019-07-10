Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D425CC74A2B
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 14:41:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C52520651
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 14:41:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C52520651
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C91E8E007A; Wed, 10 Jul 2019 10:41:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 178478E0032; Wed, 10 Jul 2019 10:41:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 040718E007A; Wed, 10 Jul 2019 10:41:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id ADBE38E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 10:41:40 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id r9so813867wme.8
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 07:41:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition
         :content-transfer-encoding:user-agent;
        bh=YhTeeRYX+I+s424rdId/3i3R3FhueIzczT6kXl/R91A=;
        b=EHBqBLtbjF36zRpkUUrGoHnUdRYG0FyWDfs1qtJeZ1A9JXMegdK0OZLT8zk1re7G5K
         CNTMTTXYPt0UymOCeDMrjoZijOHXVr2XNyDRo5vQ9D7vgt7nH8JvDsiZq8rCDnQ1r+PI
         Kp92Mb9PhaZ6oMx3xioF66oid+7BlL94AQFUaRrjXpd639TMhzSRW7uyjH3IFp8hU0gr
         kDTVUHOh2KSZPikj+VKKSF9hBiv4ENulP6jFUmhJ5XKl5zl9hAaw7UQKZf4ik76lCVVY
         nCxybcW3wo+vVIziCEFEk22mNttcGmmghY22knsmMqVv5JBdfLhi1QSC1JKqBvVfg89Q
         fT5A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
X-Gm-Message-State: APjAAAW6metrBB0p4JnqHdo82B9+JUvIeDK3XIZ74XbyTCXlcBoiu1d6
	Bp7oeI+Yv69+UMl1rkn10JSqOJZGHL6P28udfkEB6vxjUaWqXQEGe0TZnNWvi4Wm/8Hy2/TCDJs
	UMFJNvRelKJByC8mOu5i05fvZoqrRCBFhBN+sFL4rwApLCCRsjDkoBDoSTf/l9ALeBA==
X-Received: by 2002:a5d:4309:: with SMTP id h9mr30711561wrq.221.1562769700257;
        Wed, 10 Jul 2019 07:41:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx6RF1in3nFyOYZzGLaxtDLsA3Wz6U6wmPgY7exvIoYhO6NN0ApG+obo+CXWiwuiGbgP4Uf
X-Received: by 2002:a5d:4309:: with SMTP id h9mr30711501wrq.221.1562769699417;
        Wed, 10 Jul 2019 07:41:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562769699; cv=none;
        d=google.com; s=arc-20160816;
        b=1HrvcG/VdDNbYt6p4zTgjFxxipifMMx+CsIyQ3xLQTPp1zpFlNcwp0Wak/NTatxo/M
         3CxeWTB6S9D2GAfNxj1MjlJIGJKwOMD5keAKlJ5i/k3NDjY8nxgXvBelJ+90JGWsZARb
         LjXxEssZOKzbyq4ZDyIoFtqVEpc0W45WxIqVb87eYp/OZQr8KFtzQAPj3temGjs3axRC
         5QkcE/aOz7Hd+wqr6f1tDozNNRWmCkNSCyenrfbw1Xa7D3saFdN/hwdL+wNoCPMXNZ7M
         AIVEEy+cX7QkvgGhbypOLD3iJStfmD3iNbi2MYqUA/vMgdIvwoh+C+yPf9aU5dbj5dX4
         ZhlA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-transfer-encoding:content-disposition
         :mime-version:message-id:subject:cc:to:from:date;
        bh=YhTeeRYX+I+s424rdId/3i3R3FhueIzczT6kXl/R91A=;
        b=Lf+e6T2bi3jHVl3VJ0uj7kyBT/CdPj0WAiws9S5fhuA+k0jFPHima6hl75vZRrcfDV
         3pclDczHuTHdSrEiWX9uC0BTxU9ANY99Q+6pktUQyYr1kgZ+fKbfQyZDJhVKhVeiLOIk
         hWuRSOwsg3prY6vDo3UZA9daGORNtf13VexUd8oW2gNzxN/yGsFfnFJGphKBO+biOKKj
         piLlS9CEvGYUSq/Ii9n4wIfaHedSGebB/qSaN+hXOnaKjzZRh6mTEsbRXJHeBFMGBE0n
         1D1/u9xyoUzwZgMEe77UJ9t4zYqP330luvrfLlbleSkzkdOFjcSZq05/H6WRsTyOhXZf
         pZYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a0a:51c0:0:12e:550::1])
        by mx.google.com with ESMTPS id y17si2245444wma.170.2019.07.10.07.41.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 10 Jul 2019 07:41:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) client-ip=2a0a:51c0:0:12e:550::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from bigeasy by Galois.linutronix.de with local (Exim 4.80)
	(envelope-from <bigeasy@linutronix.de>)
	id 1hlDms-0004RE-Ex; Wed, 10 Jul 2019 16:41:38 +0200
Date: Wed, 10 Jul 2019 16:41:38 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: linux-mm@kvack.org
Cc: tglx@linutronix.de
Subject: Memory compaction and mlockall()
Message-ID: <20190710144138.qyn4tuttdq6h7kqx@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I've been looking at the following trace:
| cyclicte-526     0d...2.. 6876070 603us : finish_task_switch <-__schedule
| cyclicte-526     0....2.. 6876070 605us : preempt_count_sub <-finish_task=
_switch
| cyclicte-526     0....1.. 6876070 607us : preempt_count_sub <-schedule
| cyclicte-526     0....... 6876070 610us : finish_wait <-put_and_wait_on_p=
age_locked

I see put_and_wait_on_page_locked after schedule and didn't expect that.
cyclictest then blocks on a lock and switches to `kcompact'. Once it
finishes, it switches back to cyclictest:
| cyclicte-526     0....... 6876070 853us : rt_spin_unlock <-put_and_wait_o=
n_page_locked
| cyclicte-526     0....... 6876070 854us : migrate_enable <-rt_spin_unlock
| cyclicte-526     0....... 6876070 860us : up_read <-do_page_fault
| cyclicte-526     0....... 6876070 861us : __up_read <-do_page_fault
| cyclicte-526     0d...... 6876070 867us : do_PrefetchAbort <-ret_from_exc=
eption
| cyclicte-526     0d...... 6876070 868us : do_page_fault <-do_PrefetchAbort
| cyclicte-526     0....... 6876070 870us : down_read_trylock <-do_page_fau=
lt
| cyclicte-526     0....... 6876070 872us : __down_read_trylock <-do_page_f=
ault
=E2=80=A6
| cyclicte-526     0....... 6876070 914us : __up_read <-do_page_fault
| cyclicte-526     0....... 6876070 923us : sys_clock_gettime32 <-ret_fast_=
syscall
| cyclicte-526     0....... 6876070 925us : posix_ktime_get_ts <-sys_clock_=
gettime32

I did not expect a pagefault with mlockall(). I assume it has to do with
memory compaction. I have
| CONFIG_COMPACTION=3Dy
| CONFIG_MIGRATION=3Dy

and Kconfig says:
|config COMPACTION
=E2=80=A6
|                                                       You shouldn't
|           disable this option unless there really is a strong reason for
|           it and then we would be really interested to hear about that at
|           linux-mm@kvack.org.

Shouldn't COMPACTION avoid touching/moving mlock()ed pages?

Sebastian

