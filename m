Date: Mon, 14 Oct 2002 06:01:48 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.42-mm2 munmap() oops
Message-ID: <20021014130148.GA4488@holomorphy.com>
References: <20021014122014.GI2032@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20021014122014.GI2032@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, dmccr@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, Oct 14, 2002 at 05:20:14AM -0700, William Lee Irwin III wrote:
> EIP is at zap_pmd_range+0xd6/0x10c

This is the BUG() if (page_count(ptepage) > 1)


Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
