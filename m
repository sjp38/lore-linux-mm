Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4978F6B0069
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 15:27:03 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id w13so34250633wmw.0
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 12:27:03 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id u197si173843wmu.25.2016.11.14.12.27.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Nov 2016 12:27:02 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id a20so18790925wme.2
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 12:27:01 -0800 (PST)
Date: Mon, 14 Nov 2016 23:27:00 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2] mm, thb: propagation of conditional compilation in
 khugepaged.c
Message-ID: <20161114202700.GB12829@node.shutemov.name>
References: <20161114201208.11474-1-jeremy.lefaure@lse.epita.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20161114201208.11474-1-jeremy.lefaure@lse.epita.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?B?Suly6W15?= Lefaure <jeremy.lefaure@lse.epita.fr>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org

On Mon, Nov 14, 2016 at 03:12:08PM -0500, Jeremy Lefaure wrote:
> Commit b46e756f5e47 ("thp: extract khugepaged from mm/huge_memory.c")
> moved code from huge_memory.c to khugepaged.c. Some of this code should
> be compiled only when CONFIG_SYSFS is enabled but the condition around
> this code was not moved into khugepaged.c. The result is a compilation
> error when CONFIG_SYSFS is disabled:
> 
> mm/built-in.o: In function `khugepaged_defrag_store':
> khugepaged.c:(.text+0x2d095): undefined reference to
> `single_hugepage_flag_store'
> mm/built-in.o: In function `khugepaged_defrag_show':
> khugepaged.c:(.text+0x2d0ab): undefined reference to
> `single_hugepage_flag_show'
> 
> This commit adds the #ifdef CONFIG_SYSFS around the code related to
> sysfs.
> 
> Signed-off-by: Jeremy Lefaure <jeremy.lefaure@lse.epita.fr>
> ---
> After having discuted with Hillf, I changed the subject to replace "thb" by
> "mm, thb". I also rewrote the subject.

s/thb/thp/

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
