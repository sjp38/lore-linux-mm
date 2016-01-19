Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 055256B0009
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 10:47:44 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id r129so95673096wmr.0
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 07:47:43 -0800 (PST)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id 79si33996681wmb.9.2016.01.19.07.47.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jan 2016 07:47:42 -0800 (PST)
Received: by mail-wm0-x22a.google.com with SMTP id n5so118809492wmn.0
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 07:47:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160115050722.GE1993@swordfish>
References: <1452818184-2994-1-git-send-email-junil0814.lee@lge.com>
 <20160115023518.GA10843@bbox> <20160115032712.GC1993@swordfish>
 <20160115044916.GB11203@bbox> <20160115050722.GE1993@swordfish>
From: Russell Knize <rknize@motorola.com>
Date: Tue, 19 Jan 2016 09:47:12 -0600
Message-ID: <CAGfvh60CYegQ1fRMzuWbRNsv5eYEEiXtXFSBr_CbnJHuYMs5pQ@mail.gmail.com>
Subject: Re: [PATCH] zsmalloc: fix migrate_zspage-zs_free race condition
Content-Type: multipart/alternative; boundary=001a114b1378395cd70529b1ca40
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Junil Lee <junil0814.lee@lge.com>, Andrew Morton <akpm@linux-foundation.org>, ngupta@vflare.org, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

--001a114b1378395cd70529b1ca40
Content-Type: text/plain; charset=UTF-8

Just wanted to ack this, as we have been seeing the same problem (weird
race conditions during compaction) and fixed it in the same way a few weeks
ago (resetting the pin bit before recording the obj).

Russ

--001a114b1378395cd70529b1ca40
Content-Type: text/html; charset=UTF-8

<div dir="ltr">Just wanted to ack this, as we have been seeing the same problem (weird race conditions during compaction) and fixed it in the same way a few weeks ago (resetting the pin bit before recording the obj).<div><br></div><div>Russ</div></div>

--001a114b1378395cd70529b1ca40--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
