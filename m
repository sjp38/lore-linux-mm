Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 98BD36B0255
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 11:11:08 -0500 (EST)
Received: by wmec201 with SMTP id c201so219351250wme.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 08:11:08 -0800 (PST)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id 14si31312085wmq.78.2015.12.08.08.11.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 08:11:07 -0800 (PST)
Received: by wmww144 with SMTP id w144so35877931wmw.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 08:11:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <E86EADE93E2D054CBCD4E708C38D364A54298EAE@G01JPEXMBYT01>
References: <1448636635-15946-1-git-send-email-izumi.taku@jp.fujitsu.com>
	<20151207163112.930a495d24ab259cad9020ac@linux-foundation.org>
	<E86EADE93E2D054CBCD4E708C38D364A54298EAE@G01JPEXMBYT01>
Date: Tue, 8 Dec 2015 08:11:06 -0800
Message-ID: <CA+8MBbJuYwT+PWu_Amy7RWxmNvuvG++Bn9ZL3kfbkz_rByqUKg@mail.gmail.com>
Subject: Re: [PATCH v2 0/2] mm: Introduce kernelcore=reliable option
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "qiuxishi@huawei.com" <qiuxishi@huawei.com>, "Kamezawa, Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "dave.hansen@intel.com" <dave.hansen@intel.com>, "matt@codeblueprint.co.uk" <matt@codeblueprint.co.uk>

On Tue, Dec 8, 2015 at 12:07 AM, Izumi, Taku <izumi.taku@jp.fujitsu.com> wrote:
>  Which do you think is beter ?
>    - change into kernelcore="mirrored"
>    - keep kernelcore="reliable" and minmal printk fix

UEFI came up with the "reliable" wording (as a more generic term ...
as Andrew said
it could cover differences in ECC modes, or some alternate memory
technology that
has lower error rates).

But I personally like "mirror" more ... it matches current
implementation. Of course
I'll look silly if some future system does something other than mirror.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
