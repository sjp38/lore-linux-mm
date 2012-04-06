Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id AF18B6B007E
	for <linux-mm@kvack.org>; Fri,  6 Apr 2012 02:45:03 -0400 (EDT)
Received: by yenm8 with SMTP id m8so1506622yen.14
        for <linux-mm@kvack.org>; Thu, 05 Apr 2012 23:45:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1333643534-1591-3-git-send-email-b.zolnierkie@samsung.com>
References: <1333643534-1591-1-git-send-email-b.zolnierkie@samsung.com>
	<1333643534-1591-3-git-send-email-b.zolnierkie@samsung.com>
Date: Fri, 6 Apr 2012 15:45:02 +0900
Message-ID: <CAEwNFnA_QH3Ly=6Nm_Cq7vHPONCxmXOz-7OLvYa7rQOypk73XQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: compaction: allow isolation of lower order buddy pages
From: Minchan Kim <minchan@kernel.org>
Content-Type: multipart/alternative; boundary=20cf303dd276fa9ef004bcfcfeaa
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, Kyungmin Park <kyungmin.park@samsung.com>

--20cf303dd276fa9ef004bcfcfeaa
Content-Type: text/plain; charset=UTF-8

On Fri, Apr 6, 2012 at 1:32 AM, Bartlomiej Zolnierkiewicz <
b.zolnierkie@samsung.com> wrote:

> Allow lower order buddy pages in suitable_migration_target()
> so isolate_freepages() can isolate them as free pages during
> compaction_alloc() phase.
>

It could mix movable pages in unmovable block so that it would mess page
grouping up. :(


-- 
Kind regards,
Minchan Kim

--20cf303dd276fa9ef004bcfcfeaa
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Fri, Apr 6, 2012 at 1:32 AM, Bartlomi=
ej Zolnierkiewicz <span dir=3D"ltr">&lt;<a href=3D"mailto:b.zolnierkie@sams=
ung.com">b.zolnierkie@samsung.com</a>&gt;</span> wrote:<br><blockquote clas=
s=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;pad=
ding-left:1ex">
Allow lower order buddy pages in suitable_migration_target()<br>
so isolate_freepages() can isolate them as free pages during<br>
compaction_alloc() phase.<br></blockquote><div><br></div><div>It could mix =
movable pages in unmovable block so that it would mess page grouping up. :(=
</div><div><br></div></div><div><br></div>-- <br>Kind regards,<br>Minchan K=
im<br>


--20cf303dd276fa9ef004bcfcfeaa--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
