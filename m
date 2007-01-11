Date: Wed, 10 Jan 2007 16:43:36 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [REGRESSION] 2.6.19/2.6.20-rc3 buffered write slowdown
In-Reply-To: <20070111003158.GT33919298@melbourne.sgi.com>
Message-ID: <Pine.LNX.4.64.0701101642080.23729@schroedinger.engr.sgi.com>
References: <20070110223731.GC44411608@melbourne.sgi.com>
 <Pine.LNX.4.64.0701101503310.22578@schroedinger.engr.sgi.com>
 <20070110230855.GF44411608@melbourne.sgi.com> <45A57333.6060904@yahoo.com.au>
 <20070111003158.GT33919298@melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

You are comparing a debian 2.6.18 standard kernel with your tuned version 
of 2.6.20-rc3. There may be a lot of differences. Could you get us the 
config? Or use the same config file and build 2.6.20/18 the same way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
