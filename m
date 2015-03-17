Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id DD8A86B006C
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 18:57:13 -0400 (EDT)
Received: by ignm3 with SMTP id m3so62459484ign.0
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 15:57:13 -0700 (PDT)
Received: from mail-ie0-x231.google.com (mail-ie0-x231.google.com. [2607:f8b0:4001:c03::231])
        by mx.google.com with ESMTPS id r2si421417igh.8.2015.03.17.15.57.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Mar 2015 15:57:13 -0700 (PDT)
Received: by iecsl2 with SMTP id sl2so24110222iec.1
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 15:57:13 -0700 (PDT)
Date: Tue, 17 Mar 2015 15:57:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] clean up to just return ERR_PTR
In-Reply-To: <1426580713-21151-2-git-send-email-denc716@gmail.com>
Message-ID: <alpine.DEB.2.10.1503171553540.11185@chino.kir.corp.google.com>
References: <1426580713-21151-1-git-send-email-denc716@gmail.com> <1426580713-21151-2-git-send-email-denc716@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: denc716@gmail.com
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Derek Che <crquan@ymail.com>

On Tue, 17 Mar 2015, denc716@gmail.com wrote:

> Signed-off-by: Derek Che <crquan@ymail.com>
> Acked-by: "Kirill A. Shutemov" <kirill@shutemov.name>
> Acked-by: David Rientjes <rientjes@google.com>

I don't believe Kirill ever acked this patch, you need to wait for the 
person to respond to your email with the line themself before you can add 
it to your commit message.  Please see Documentation/SubmittingPatches.

He also suggested that this patch be done, so you need to add

Suggested-by: Kirill A. Shutemov <kirill@shutemov.name>

You need a proper subject line for the patch, in this case it would be 
something like "mm, mremap: avoid unnecessary gotos in vma_to_resize()" 
and you also need a proper commit message such as:

	The "goto"s in vma_to_resize() aren't necessary since they just
	return a specific value.  Switch these statements to explicit
	return statements.

My acked-by was never given before this, but it can be added because it 
looks good:

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
