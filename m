Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: Why *not* rmap, anyway?
Date: Wed, 8 May 2002 01:15:28 +0200
References: <Pine.LNX.4.44L.0205071620270.7447-100000@duckman.distro.conectiva> <E175Ary-0000Th-00@starship> <20020507212123.GZ15756@holomorphy.com>
In-Reply-To: <20020507212123.GZ15756@holomorphy.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E175EB7-0000UN-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Christian Smith <csmith@micromuse.com>, Joseph A Knapka <jknapka@earthlink.net>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 07 May 2002 23:21, William Lee Irwin III wrote:
> There are a couple of things I should probably say about my prior efforts.
> 
> The plan back then was to hide the pagetable structure from generic code
> altogether and allow architecture-specific code to export a procedural
> interface totally insulating the core from the structure of pagetables.
> This was largely motivated by the notion that the optimal pagetable
> structure could be chosen on a per-architecture basis. Linus himself
> informed me that there was evidence to the contrary regarding
> architecture-specific optimal pagetable structures, and so I abandoned
> that effort given the evidence the scheme was pessimal.
> 
> I have no plans now to change the standardized structure or to export
> a HAT from arch code. OTOH I've faced some recent reminders of what the
> code looks like now and believe janitoring may well be in order.

Swap_off is deeply disgusting and needs a rototilling.  Some others like
copy_page_range and remap_page_range are fine.  Zap_page_range has
superficial defects.  Other than swap_off, there are no really obviously
bleeding wounds.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
