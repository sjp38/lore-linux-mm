Message-ID: <3D48C1AD.56DDDEE0@zip.com.au>
Date: Wed, 31 Jul 2002 22:05:49 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: the ntpd bug
References: <3D48B4AD.6BF32781@zip.com.au>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> 
> ...
> I saw one rather strange looking thing which appears to add
> two pte_chains for a single pte.  But this patch:
> 

is broken.  Please ignore.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
