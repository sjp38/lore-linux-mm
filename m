Date: Wed, 30 Jan 2008 15:49:17 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] SLUB: Fix sysfs refcounting
In-Reply-To: <20080130153536.0504afe2.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0801301545350.1722@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0801291940310.22715@schroedinger.engr.sgi.com>
 <20080130153536.0504afe2.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

On Wed, 30 Jan 2008, Andrew Morton wrote:

> Sorry, but the changelogging here is inadequate.  What is incorrect about
> the current behaviour and how does this patch improve things?  What are the
> consequences of not merging this patch?  Leak?  Crash?
> 
> One of the reasons why this information is important is so I can make a
> do-we-need-this-in-stable decision.

Last time I sent it to you was Dec 27th. You forwarded to Al Viro but no 
response.
