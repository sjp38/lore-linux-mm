From: Marc-Christian Petersen <m.c.p@wolk-project.de>
Subject: Re: [PATCH] 2.6.4-rc2-mm1: vm-split-active-lists
Date: Thu, 11 Mar 2004 18:25:22 +0100
References: <404FACF4.3030601@cyberone.com.au>
In-Reply-To: <404FACF4.3030601@cyberone.com.au>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Message-Id: <200403111825.22674@WOLK>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Nick Piggin <piggin@cyberone.com.au>, linux-mm@kvack.org, Mike Fedyk <mfedyk@matchmail.com>, plate@gmx.tm
List-ID: <linux-mm.kvack.org>

On Thursday 11 March 2004 01:04, Nick Piggin wrote:

Hi Nick,

> Here is my updated patches rolled into one.

hmm, using this in 2.6.4-rc2-mm1 my machine starts to swap very very soon. 
Machine has squid, bind, apache running, X 4.3.0, Windowmaker, so nothing 
special.

Swap grows very easily starting to untar'gunzip a kernel tree. About + 
150-200MB goes to swap. Everything is very smooth though, but I just wondered 
because w/o your patches swap isn't used at all, even after some days of 
uptime.

ciao, Marc

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
