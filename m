Message-ID: <404D5A6F.4070300@matchmail.com>
Date: Mon, 08 Mar 2004 21:47:27 -0800
From: Mike Fedyk <mfedyk@matchmail.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 4/4] vm-mapped-x-active-lists
References: <404D56D8.2000008@cyberone.com.au> <404D5784.9080004@cyberone.com.au>
In-Reply-To: <404D5784.9080004@cyberone.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> 
> 
> ------------------------------------------------------------------------
> 
> 
> Split the active list into mapped and unmapped pages.

This looks similar to Rik's Active and Active-anon lists in 2.4-rmap.

Also, how does this interact with Andrea's VM work?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
