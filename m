Date: Sun, 2 Feb 2003 12:06:04 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: hugepage patches
Message-ID: <20030202200604.GE29981@holomorphy.com>
References: <20030131151501.7273a9bf.akpm@digeo.com> <20030202025609.7e20a22c.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030202025609.7e20a22c.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: davem@redhat.com, rohit.seth@intel.com, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Feb 02, 2003 at 02:56:09AM -0800, Andrew Morton wrote:
> hugetlbfs cleanups
> - Remove quota code.
> - Remove extraneous copy-n-paste code from truncate: that's only for
>   physically-backed filesystems.
> - Whitespace changes.

quotas wold allow per-user limits on the memory consumed with the stuff.
I guess since I've not pursued it / tested it / etc. out it goes...


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
