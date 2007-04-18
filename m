Message-ID: <4625A341.1090102@google.com>
Date: Tue, 17 Apr 2007 21:49:05 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: Re: meminfo returns inaccurate NR_FILE_PAGES
References: <46255446.6060204@google.com> <Pine.LNX.4.64.0704171655390.9381@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0704171655390.9381@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Fix NR_FILE_PAGES and NR_ANON_PAGES accounting.
>   

    One other thing -- I think you're confusing NR_FILE_PAGES with 
NR_FILE_MAPPED. Either NR_FILE_MAPPED or NR_ANON_PAGES is set in rmap.c 
depending upon the whether the page is anon. NR_FILE_PAGES is set in 
filemap.c in the page cache functions.
    -- Ethan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
