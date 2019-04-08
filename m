Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB90EC10F13
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 19:58:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8BB3A20880
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 19:58:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Fy4t1CyU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8BB3A20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 21FF36B0008; Mon,  8 Apr 2019 15:58:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1CF526B000A; Mon,  8 Apr 2019 15:58:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BF3C6B000C; Mon,  8 Apr 2019 15:58:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id C2BCB6B0008
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 15:58:18 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 4so10673694plb.5
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 12:58:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=29W9ucIOqItYnzmL2gQIQ5ExGyQgwi2PVG1yglWaKBM=;
        b=hxMyuD554iAbMdVsBzMReGT/iggMt2S5wIEj+2zKZVKVQ8RUYyGGT/aJMSFq61JBch
         yecjBtw38fLQWhcSYYfh/l0FPanx8vBRHGHtyipo3Dl/svD1kFZDHbBRgMCCN0Qdt+v8
         XmJWWlTR1A0wD38KZjGmyhnNq/lx8PekrgzhCpamk59TFGD7LBgGrRl5Q2kv88G03IvG
         WbBsnBgqa9uN7SbxAiihS1hqfswLQtrpvH6Z6hi89mn+xbd76TwWW0Aeaw/rVhBZgZq/
         neyfjBR+hDDOv5b1NMxZelQDB9JRMqedUnNDxyX/BG0B+4ikmfhQtT/g7zBL7n6jPGju
         k1Pw==
X-Gm-Message-State: APjAAAWelubiuHFCPiXjTzGwEvUK0dnlzkjn7lFaJblhAFr/Uzof4xtw
	1EqluICE4G6IOLgA+u3Exqn9vPYUWhNqCiFoG3+NFAWawV/ugJ/yfzfol+XFAHXujM12y28Rp32
	8jDHAGPuTAFUD3k9Nr++79mzNzbqJ6+DMQ05lY1VhKGtsx/AN8WjhDwuB6Uo+S/y77A==
X-Received: by 2002:a62:3892:: with SMTP id f140mr31668405pfa.128.1554753498403;
        Mon, 08 Apr 2019 12:58:18 -0700 (PDT)
X-Received: by 2002:a62:3892:: with SMTP id f140mr31668350pfa.128.1554753497664;
        Mon, 08 Apr 2019 12:58:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554753497; cv=none;
        d=google.com; s=arc-20160816;
        b=uO/B/JuXd3+HOBh9JtbbohlkYzaCE844YjBewHCFDkdCftOYcJBWnuxHQDuHFSJNBZ
         atx2FBtHkGTreeUJoqUWRCnX/31QFRyLOsx6LQDHfEApsYgKpQIOiXo2ZX6RkCa4XA0Z
         ApRy/mmMFUBbhUr64E9Rl/i2GlA0UXOx4mf10pqLwroBg5mWd+8R6o3CgP177fucTb90
         5BXhWwTxEZTx/HpRHN7SIoTAc8ykeUbDFo18TWeA4GIbt9j7B0Ft7vXcW2KtL47TCcF3
         xb0rnmjE6WDv2n+PEmiIJv2Qo742+Fpvl/mIeNqwh/+BA75XHbMVQcf9V5jxQVFJeMPO
         fGZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=29W9ucIOqItYnzmL2gQIQ5ExGyQgwi2PVG1yglWaKBM=;
        b=hyqIXgk9MNN6E96HY8zJzkSGAKuzy6kxnDIe4EvgCST9eOBs0ga6hA29WOeGn5cjTP
         sdoJejsUw4hBpLlw6CS9XpQFzlMeczyso339RoLOzaUSc/q4CwrqMFJTVr/mVNmws3z6
         lqXGHt+SEmxHlz5ZfXKX4FfYX4Z2kwETRyJ40XVodLK9wGm3KVpypUHGsbWChcgt7l2g
         XtXCLDBCxG76mplt97WrJciydTgAajUr8+fHZiyIpEbWMWNJEanIZU80OVJe5O/X7GiC
         UCtfZytRsorFZMYx+wjnU7tiboDglro6na2eLfTG2ydjjH8B7FqeEa3Z3D4vf+fO+SlQ
         LFjg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Fy4t1CyU;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t65sor31766194pfb.3.2019.04.08.12.58.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Apr 2019 12:58:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Fy4t1CyU;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=29W9ucIOqItYnzmL2gQIQ5ExGyQgwi2PVG1yglWaKBM=;
        b=Fy4t1CyUr8Vd/Tq1kRsSKxv77weNKQj5DhgPy9nD2bCEsiBn3FEGyA8sZ83Fpwo6bW
         tRb1hXjVG3V8vMhxBjeLI6C1RvZMzNOtU33E4GDSDs0Ps0T0NgRjLBkn9n5ALGsshrwb
         Oxspjm1t7dapzNkUm1UBxH7cqGC7RV4j4v9uZukrNkd09KxA+zKmao0FCp1YBCvYdbAN
         76r1I75mjP8bgo4nUEuuqhIjwkoGsrIzEzuTrPl0JUP+dwFcE0tW06qlb0KlIOOev7tg
         5f+JD1JqYlb1nfbuCaPOdDZFwIKIgmIe2jO8gc4TX04rNrLUFEsId6g6YZYGYoCqlm2Z
         r0zA==
X-Google-Smtp-Source: APXvYqwgOOpcElBS1UxKQNb+mYhbX92mCmLobuI2RnT22NAeFYi++VncsNYP/Uv6ILgmoBb2UinsgQ==
X-Received: by 2002:a62:209c:: with SMTP id m28mr31113893pfj.233.1554753496623;
        Mon, 08 Apr 2019 12:58:16 -0700 (PDT)
Received: from [100.112.89.103] ([104.133.8.103])
        by smtp.gmail.com with ESMTPSA id l5sm55488310pfi.97.2019.04.08.12.58.15
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 08 Apr 2019 12:58:15 -0700 (PDT)
Date: Mon, 8 Apr 2019 12:58:14 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Andrew Morton <akpm@linux-foundation.org>
cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, 
    "Alex Xu (Hello71)" <alex_y_xu@yahoo.ca>, 
    Vineeth Pillai <vpillai@digitalocean.com>, 
    Kelley Nielsen <kelleynnn@gmail.com>, Rik van Riel <riel@surriel.com>, 
    Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, 
    linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: [PATCH 2/4] mm: swapoff: remove too limiting SWAP_UNUSE_MAX_TRIES
In-Reply-To: <alpine.LSU.2.11.1904081249370.1523@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1904081256170.1523@eggly.anvils>
References: <alpine.LSU.2.11.1904081249370.1523@eggly.anvils>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SWAP_UNUSE_MAX_TRIES 3 appeared to work well in earlier testing, but
further testing has proved it to be a source of unnecessary swapoff
EBUSY failures (which can then be followed by unmount EBUSY failures).

When mmget_not_zero() or shmem's igrab() fails, there is an mm exiting
or inode being evicted, freeing up swap independent of try_to_unuse().
Those typically completed much sooner than the old quadratic swapoff,
but now it's more common that swapoff may need to wait for them.

It's possible to move those cases from init_mm.mmlist and shmem_swaplist
to separate "exiting" swaplists, and try_to_unuse() then wait for those
lists to be emptied; but we've not bothered with that in the past, and
don't want to risk missing some other forgotten case. So just revert
to cycling around until the swap is gone, without any retries limit.

Fixes: b56a2d8af914 ("mm: rid swapoff of quadratic complexity")
Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/swapfile.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

--- 5.1-rc4/mm/swapfile.c	2019-03-17 16:18:15.713823942 -0700
+++ linux/mm/swapfile.c	2019-04-07 19:15:01.269054187 -0700
@@ -2023,7 +2023,6 @@ static unsigned int find_next_to_unuse(s
  * If the boolean frontswap is true, only unuse pages_to_unuse pages;
  * pages_to_unuse==0 means all pages; ignored if frontswap is false
  */
-#define SWAP_UNUSE_MAX_TRIES 3
 int try_to_unuse(unsigned int type, bool frontswap,
 		 unsigned long pages_to_unuse)
 {
@@ -2035,7 +2034,6 @@ int try_to_unuse(unsigned int type, bool
 	struct page *page;
 	swp_entry_t entry;
 	unsigned int i;
-	int retries = 0;
 
 	if (!si->inuse_pages)
 		return 0;
@@ -2117,14 +2115,16 @@ retry:
 	 * If yes, we would need to do retry the unuse logic again.
 	 * Under global memory pressure, swap entries can be reinserted back
 	 * into process space after the mmlist loop above passes over them.
-	 * Its not worth continuosuly retrying to unuse the swap in this case.
-	 * So we try SWAP_UNUSE_MAX_TRIES times.
+	 *
+	 * Limit the number of retries? No: when shmem_unuse()'s igrab() fails,
+	 * a shmem inode using swap is being evicted; and when mmget_not_zero()
+	 * above fails, that mm is likely to be freeing swap from exit_mmap().
+	 * Both proceed at their own independent pace: we could move them to
+	 * separate lists, and wait for those lists to be emptied; but it's
+	 * easier and more robust (though cpu-intensive) just to keep retrying.
 	 */
-	if (++retries >= SWAP_UNUSE_MAX_TRIES)
-		retval = -EBUSY;
-	else if (si->inuse_pages)
+	if (si->inuse_pages)
 		goto retry;
-
 out:
 	return (retval == FRONTSWAP_PAGES_UNUSED) ? 0 : retval;
 }

