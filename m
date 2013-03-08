Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 58C5D6B0006
	for <linux-mm@kvack.org>; Fri,  8 Mar 2013 04:04:31 -0500 (EST)
Message-ID: <5139A996.4070303@parallels.com>
Date: Fri, 08 Mar 2013 13:04:22 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: Unexpected mremap + shared anon mapping behavior
References: <5139A10C.3060507@parallels.com> <20130308085301.GB4411@shutemov.name>
In-Reply-To: <20130308085301.GB4411@shutemov.name>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Linux MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>

>> So, the question is -- what should the mremap() behavior be for shared anonymous mappings?
>> Should it truncate the file to match the grown-up vma length? If yes, should it also 
>> truncate it if we mremap() the mapping to the smaller size?
> 
> I think the answer is 'no' for both cases. It's ABI change.
> 
> Should we introduce mtruncate() syscall which will truncate backing fail
> in both cases? ;)
> 

If we don't touch kernel mremap, then mtruncate can be done in glibc via /proc/pid/map_files :)

Thanks,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
