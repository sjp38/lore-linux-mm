From: mel@skynet.ie (Mel Gorman)
Subject: Re: [PATCH 7/7] Compact memory directly by a process when a high-order allocation fails
Date: Tue, 19 Jun 2007 17:50:57 +0100
Message-ID: <20070619165057.GF17109@skynet.ie>
References: <20070618092821.7790.52015.sendpatchset@skynet.skynet.ie> <20070618093042.7790.30669.sendpatchset@skynet.skynet.ie> <Pine.LNX.4.64.0706181022060.4751@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760158AbXFSQvP@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706181022060.4751@schroedinger.engr.sgi.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com
List-Id: linux-mm.kvack.org

On (18/06/07 10:22), Christoph Lameter didst pronounce:
> You are amazing.
> 

Thanks! 

There are still knots that need ironing out but I believe the core idea
is solid and can be built into something useful.

Thanks for reviewing.

> Acked-by: Christoph Lameter <clameter@sgi.com>
> 

-- 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab
