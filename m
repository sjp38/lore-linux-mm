From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14268.9729.735429.46615@dukat.scot.redhat.com>
Date: Thu, 19 Aug 1999 16:42:57 +0100 (BST)
Subject: Re: [PATCH] ext2_updatepage for 2.2.11
In-Reply-To: <199908161138.MAA28349@dukat.scot.redhat.com>
References: <199908161138.MAA28349@dukat.scot.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: sct@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 16 Aug 1999 12:38:17 +0100, "Benjamin C.R. LaHaise"
<blah@kvack.org> said:

> Hello Stephen et all,
> Below is my version of a fix for the SMP shared mmap bug by making ext2
> write through the page cache using generic_file_write, 

I'm not sure we want to introduce such significant changes into 2.2,
and 2.3 already has equivalent code now.  Yes, we do need this stuff,
but in 2.2?

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
