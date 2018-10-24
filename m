Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id B3BEE6B0003
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 21:17:07 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id x10-v6so2555899wrs.10
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 18:17:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 136-v6sor2195613wmb.26.2018.10.23.18.17.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Oct 2018 18:17:05 -0700 (PDT)
From: Michael Jones <mj@mikejonesey.co.uk>
Subject: re: [PATCH] kernel:mm/vmstat.c: correct typo in comment to variables
 for counters.
Message-ID: <962da370-9f6f-9543-bc7c-42c71b6cb2bc@mikejonesey.co.uk>
Date: Wed, 24 Oct 2018 02:17:03 +0100
MIME-Version: 1.0
Content-Type: multipart/alternative;
 boundary="------------25D141CD796573E0B214E844"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: trivial@kernel.org

This is a multi-part message in MIME format.
--------------25D141CD796573E0B214E844
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Signed-off-by: Michael Jones <mj@mikejonesey.co.uk>

commit 012af68d1e66525390aa37c70d28ac2e191894ff
Author: Michael Jones <mj@mikejonesey.co.uk>
Date:   Wed Oct 24 01:40:13 2018 +0100

    mm/vmstat.c: correct typo in comment
   =20
    no functional change, just correcting a typo in comments.

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 7878da76abf2..158c23bfbcf5 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1106,7 +1106,7 @@ int fragmentation_index(struct zone *zone, unsigned=
 int order)
                                        TEXT_FOR_HIGHMEM(xx) xx "_movable=
",
=20
 const char * const vmstat_text[] =3D {
-       /* enum zone_stat_item countes */
+       /* enum zone_stat_item counters */
        "nr_free_pages",
        "nr_zone_inactive_anon",
        "nr_zone_active_anon",


--------------25D141CD796573E0B214E844
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 8bit

<html>
  <head>

    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
  </head>
  <body bgcolor="#FFFFFF" text="#000000">
    <pre><span></span>Signed-off-by: Michael Jones <a class="moz-txt-link-rfc2396E" href="mailto:mj@mikejonesey.co.uk">&lt;mj@mikejonesey.co.uk&gt;</a>

commit 012af68d1e66525390aa37c70d28ac2e191894ff
Author: Michael Jones <a class="moz-txt-link-rfc2396E" href="mailto:mj@mikejonesey.co.uk">&lt;mj@mikejonesey.co.uk&gt;</a>
Date:   Wed Oct 24 01:40:13 2018 +0100

    mm/vmstat.c: correct typo in comment
    
    no functional change, just correcting a typo in comments.

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 7878da76abf2..158c23bfbcf5 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1106,7 +1106,7 @@ int fragmentation_index(struct zone *zone, unsigned int order)
                                        TEXT_FOR_HIGHMEM(xx) xx "_movable",
 
 const char * const vmstat_text[] = {
-       /* enum zone_stat_item countes */
+       /* enum zone_stat_item counters */
        "nr_free_pages",
        "nr_zone_inactive_anon",
        "nr_zone_active_anon",

</pre>
  </body>
</html>

--------------25D141CD796573E0B214E844--
