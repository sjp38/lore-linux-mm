Date: Wed, 8 Aug 2007 10:38:13 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/3] Use zonelists instead of zones when direct reclaiming
 pages
In-Reply-To: <20070808161524.32320.87008.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0708081037450.12652@schroedinger.engr.sgi.com>
References: <20070808161504.32320.79576.sendpatchset@skynet.skynet.ie>
 <20070808161524.32320.87008.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Lee.Schermerhorn@hp.com, pj@sgi.com, ak@suse.de, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Good idea. Maybe it could be taken further by passing the zonelist also 
into shrink_zones()?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
