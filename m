From: Christoph Lameter <clameter@sgi.com>
Subject: Re: NUMA BOF @OLS
Date: Thu, 21 Jun 2007 18:46:14 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0706211844420.11754@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0706211316150.9220@schroedinger.engr.sgi.com>
 <200706220112.51813.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753891AbXFVBqZ@vger.kernel.org>
In-Reply-To: <200706220112.51813.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

On Fri, 22 Jun 2007, Arnd Bergmann wrote:

> - Interface for preallocating hugetlbfs pages per node instead of system wide

We may want to get a bit higher level than that. General way of 
controlling subsystem use on nodes. One wants to restrict the slab 
allocator and the kernel etc on nodes too.

How will this interact with the other NUMA policy specifications?
 
> - architecture independent in-kernel API for enumerating CPU sockets with
>   multicore processors (not sure if that's the same as your existing subject).

Not sure what you mean by this. We already have a topology interface and 
the scheduler knows about these things.
