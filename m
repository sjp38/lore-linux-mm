Date: Fri, 8 Jun 2007 12:08:30 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 00/12] Slab defragmentation V3
In-Reply-To: <6bffcb0e0706081156u4ad0cc9dkf6d55ebcbd79def2@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0706081207400.2082@schroedinger.engr.sgi.com>
References: <20070607215529.147027769@sgi.com>  <466999A2.8020608@googlemail.com>
  <Pine.LNX.4.64.0706081110580.1464@schroedinger.engr.sgi.com>
 <6bffcb0e0706081156u4ad0cc9dkf6d55ebcbd79def2@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

On Fri, 8 Jun 2007, Michal Piotrowski wrote:

> Yes, it does. Thanks!

Ahhh... That leds to the discovery more sysfs problems. I need to make 
sure not to be holding locks while calling into sysfs. More cleanup...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
