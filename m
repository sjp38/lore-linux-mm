Date: Wed, 17 Sep 2003 13:43:12 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: How best to bypass the page cache from within a kernel module?
Message-ID: <20030917204312.GJ14079@holomorphy.com>
References: <20030917195044.GH14079@holomorphy.com> <Pine.LNX.4.44L0.0309171617560.1646-100000@ida.rowland.org> <20030917204047.GI14079@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030917204047.GI14079@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Stern <stern@rowland.harvard.edu>, Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 17, 2003 at 01:40:47PM -0700, William Lee Irwin III wrote:
> or some such, or handle_mm_fault() depending on what you have in mind

s/handle_mm_fault/make_pages_present/


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
