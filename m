Date: Thu, 27 Feb 2003 14:11:51 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Top 128MB of virtual address space
Message-ID: <20030227221151.GA24172@holomorphy.com>
References: <3E5E8832.688AE0CB@watson.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3E5E8832.688AE0CB@watson.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Raymond B. Jennings III" <raymondj@watson.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 27, 2003 at 04:50:42PM -0500, Raymond B. Jennings III wrote:
> For linux running on an Intel machine without PAE, the top 128MB of
> virtual address space:
> If
> PKMAP_BASE = FE000000
> and
> FIXADDR_START=FFF55000
> That leaves a 32MB area.  I believe the permanent highmem mappings are
> 1024 pages so that leaves 28MB of address space.  What is this space
> used for if anything?

Nothing. This is fixed in 2.5

-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
