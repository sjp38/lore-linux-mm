Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 109D1C282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 16:04:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CFD152171F
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 16:04:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CFD152171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6AF5B8E0002; Mon, 28 Jan 2019 11:04:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 65D868E0001; Mon, 28 Jan 2019 11:04:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 573848E0002; Mon, 28 Jan 2019 11:04:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2E0438E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 11:04:10 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id w19so21146496qto.13
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 08:04:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=3g8ukPIuxvnYpp4ZZrXM2L/pRIG1RvRhag6XFgOk9Bw=;
        b=WqShtvrn+PNpob2sC58Pf9WhZtbScPjefaZdO5qBCGIXxC+Ph+Bq/npeJkGIHDcvtF
         3gfLeWQ86qNyktX8HUVkso1I/wpylaFwiwaZuLfZCC/cS9utCnJ2WiLl98AFKgQjuEd/
         PyZZZbi3gNadIp6EjoDmIGC8XcQobkr8BHRnmO9eL4nx8iag23fCPg5YOQ/PhO5Rn+q0
         OeCjfowZtfZuaFQIna+GbgmHep3lrSOobI7Nvz++6wmZW5Ei/+t4+RbmjwJu3Yvrp+nY
         NS0RHRHOxr+zn4WCOXdX564zGDw6Mwi+ivsyJfMlNboeZSo32ue7hxVOFvx88c2eiV5B
         B10g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukfMJXfZonNuwhsVsGtnTvRKBQU2ZpxBB4Pgkoma2ck845VpPgpm
	rdjJ8Kxj+X+nIRZTAoF283HB8G4NG7JBq8mE1KrXy0EjPFxnoGH7F8FWvUaF/T0slGSiIPKN5yP
	F19kQf/6pLJ4sxotE9IQ17wXTkAa4rn1qv7x9Rr/RRLuZgJPpnrpeG+71hOCSIBa42A==
X-Received: by 2002:ae9:dec5:: with SMTP id s188mr19805212qkf.127.1548691449935;
        Mon, 28 Jan 2019 08:04:09 -0800 (PST)
X-Google-Smtp-Source: ALg8bN41j7e94ghpdHExTmVbWKyUl4bNosh7Z6iv8Sw7KiWJZpVGwHIvpjcFPjVGyDxjgqS6Et5l
X-Received: by 2002:ae9:dec5:: with SMTP id s188mr19805158qkf.127.1548691449208;
        Mon, 28 Jan 2019 08:04:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548691449; cv=none;
        d=google.com; s=arc-20160816;
        b=PG0y4r6xOq+L2b9+knusUuFDGHQ0O7qtq8JTbGI30ygximP4zaOWmWhEzkv6QRNX+9
         TiGsCwhhr096b0K9cFOleZEGBA30/kqC4kKd5Aqad7E7briH+UJ1trIVWBR9PBv9daOB
         pNo22nfQPVfpufidZd/Zv1IkOxw6t7s3ZuEMy1HKTBGczgy/V1+Ykq71t874pAeVfDSj
         42+bohacK6xK96t+wA7DXwXzC1js5MYH7faAmgqOxLcXmfdgYG+i3/5N+HcSe3Qkur5k
         UsXdvh/gE5cgsArsH6KZ2LZu/nlZHRkl39XHaTtt1cmdRpXPPOg5bgHku1tHVgMQHe4z
         wxjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=3g8ukPIuxvnYpp4ZZrXM2L/pRIG1RvRhag6XFgOk9Bw=;
        b=fmDBZb3gtsoqfDZKTNxsD7N+8GKeP86FWBZGGdrMSTb1qs92XYgORsREXs6ootk2jc
         FGXa+I6HDr59hxDVYCQpa7jQ06t6be/QObPr2CVNNfPlj6ilbGG3P3SMa0whcylZ6eoL
         pbbUmIDbwY7z5AkG78HftgPHLlvXzNHH/vw+ecdYO3xN0PNQm4PMCig4tF1VbAsnijjk
         1y1HMRbatkYaFMwtZG41dO331AThWisKUwd759oD/lM3YNBdobQj6y22qx5mXcZ+mHgg
         XtKwJTd5B/vgp9u/7ChIo9dWPqog6t9Dz5tuS/10t+2EHSfkFQ7tYIeV4XpGxRYK7Z/R
         +flg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d13si1502617qto.267.2019.01.28.08.04.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 08:04:09 -0800 (PST)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F3B5BA08EC;
	Mon, 28 Jan 2019 16:04:07 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-107.ams2.redhat.com [10.36.117.107])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7221710E1B41;
	Mon, 28 Jan 2019 16:04:04 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Jan Kara <jack@suse.cz>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Dominik Brodowski <linux@dominikbrodowski.net>,
	Matthew Wilcox <willy@infradead.org>,
	Vratislav Bendel <vbendel@redhat.com>,
	Rafael Aquini <aquini@redhat.com>,
	Konstantin Khlebnikov <k.khlebnikov@samsung.com>,
	Minchan Kim <minchan@kernel.org>,
	stable@vger.kernel.org
Subject: [PATCH v1] mm: migrate: don't rely on PageMovable() of newpage after unlocking it
Date: Mon, 28 Jan 2019 17:04:03 +0100
Message-Id: <20190128160403.16657-1-david@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Mon, 28 Jan 2019 16:04:08 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190128160403.Fvdv68t98iXhMk85-_JK8Mhadbd1L-8sdT8iNNZgWAY@z>

While debugging some crashes related to virtio-balloon deflation that
happened under the old balloon migration code, I stumbled over a race
that still exists today.

What we experienced:

drivers/virtio/virtio_balloon.c:release_pages_balloon():
- WARNING: CPU: 13 PID: 6586 at lib/list_debug.c:59 __list_del_entry+0xa1/0xd0
- list_del corruption. prev->next should be ffffe253961090a0, but was dead000000000100

Turns out after having added the page to a local list when dequeuing,
the page would suddenly be moved to an LRU list before we would free it
via the local list, corrupting both lists. So a page we own and that is
!LRU was moved to an LRU list.

In __unmap_and_move(), we lock the old and newpage and perform the
migration. In case of vitio-balloon, the new page will become
movable, the old page will no longer be movable.

However, after unlocking newpage, there is nothing stopping the newpage
from getting dequeued and freed by virtio-balloon. This
will result in the newpage
1. No longer having PageMovable()
2. Getting moved to the local list before finally freeing it (using
   page->lru)

Back in the migration thread in __unmap_and_move(), we would after
unlocking the newpage suddenly no longer have PageMovable(newpage) and
will therefore call putback_lru_page(newpage), modifying page->lru
although that list is still in use by virtio-balloon.

To summarize, we have a race between migrating the newpage and checking
for PageMovable(newpage). Instead of checking PageMovable(newpage), we
can simply rely on is_lru of the original page.

Looks like this was introduced by d6d86c0a7f8d ("mm/balloon_compaction:
redesign ballooned pages management"), which was backported up to 3.12.
Old compaction code used PageBalloon() via -_is_movable_balloon_page()
instead of PageMovable(), however with the same semantics.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Vratislav Bendel <vbendel@redhat.com>
Cc: Rafael Aquini <aquini@redhat.com>
Cc: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: stable@vger.kernel.org # 3.12+
Fixes: d6d86c0a7f8d ("mm/balloon_compaction: redesign ballooned pages management")
Reported-by: Vratislav Bendel <vbendel@redhat.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Rafael Aquini <aquini@redhat.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/migrate.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 4512afab46ac..31e002270b05 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1135,10 +1135,12 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 	 * If migration is successful, decrease refcount of the newpage
 	 * which will not free the page because new page owner increased
 	 * refcounter. As well, if it is LRU page, add the page to LRU
-	 * list in here.
+	 * list in here. Don't rely on PageMovable(newpage), as that could
+	 * already have changed after unlocking newpage (e.g.
+	 * virtio-balloon deflation).
 	 */
 	if (rc == MIGRATEPAGE_SUCCESS) {
-		if (unlikely(__PageMovable(newpage)))
+		if (unlikely(!is_lru))
 			put_page(newpage);
 		else
 			putback_lru_page(newpage);
-- 
2.17.2

