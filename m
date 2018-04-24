Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id DDA3C6B0005
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 15:05:07 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x16so939932wmc.8
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 12:05:07 -0700 (PDT)
Received: from lithops.sigma-star.at (lithops.sigma-star.at. [195.201.40.130])
        by mx.google.com with ESMTPS id w23si3484233edr.80.2018.04.24.12.05.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Apr 2018 12:05:06 -0700 (PDT)
From: Richard Weinberger <richard@nod.at>
Subject: Re: vmalloc with GFP_NOFS
Date: Tue, 24 Apr 2018 21:05:05 +0200
Message-ID: <1715857.C3bTW05DZe@blindfold>
In-Reply-To: <20180424162712.GL17484@dhcp22.suse.cz>
References: <20180424162712.GL17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="nextPart1929745.k0RrSNZNOz"
Content-Transfer-Encoding: 7Bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Artem Bityutskiy <dedekind1@gmail.com>, David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Marek Vasut <marek.vasut@gmail.com>, Cyrille Pitchen <cyrille.pitchen@wedev4u.fr>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Steven Whitehouse <swhiteho@redhat.com>, Bob Peterson <rpeterso@redhat.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, Adrian Hunter <adrian.hunter@intel.com>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, Mikulas Patocka <mpatocka@redhat.com>, linux-mtd@lists.infradead.org, linux-ext4@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, linux-mm@kvack.org

This is a multi-part message in MIME format.

--nextPart1929745.k0RrSNZNOz
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

Am Dienstag, 24. April 2018, 18:27:12 CEST schrieb Michal Hocko:
> Hi,
> it seems that we still have few vmalloc users who perform GFP_NOFS
> allocation:
> drivers/mtd/ubi/io.c

UBI is also not a big deal. We use it here like in UBIFS for debugging
when self-checks are enabled.

Thanks,
//richard

--nextPart1929745.k0RrSNZNOz
Content-Transfer-Encoding: 7Bit
Content-Type: text/html; charset="us-ascii"

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN" "http://www.w3.org/TR/REC-html40/strict.dtd">
<html><head><meta name="qrichtext" content="1" /><style type="text/css">
p, li { white-space: pre-wrap; }
</style></head><body style=" font-family:'Hack'; font-size:10pt; font-weight:400; font-style:normal;">
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">Am Dienstag, 24. April 2018, 18:27:12 CEST schrieb Michal Hocko:</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; Hi,</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; it seems that we still have few vmalloc users who perform GFP_NOFS</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; allocation:</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">&gt; drivers/mtd/ubi/io.c</p>
<p style="-qt-paragraph-type:empty; margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; ">&nbsp;</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">UBI is also not a big deal. We use it here like in UBIFS for debugging</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">when self-checks are enabled.</p>
<p style="-qt-paragraph-type:empty; margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; ">&nbsp;</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">Thanks,</p>
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; -qt-user-state:0;">//richard</p></body></html>
--nextPart1929745.k0RrSNZNOz--
