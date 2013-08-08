Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 88C718D0001
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 04:42:15 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20130807213736.AC732E0090@blue.fi.intel.com>
References: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1375582645-29274-2-git-send-email-kirill.shutemov@linux.intel.com>
 <20130805111739.GA25691@quack.suse.cz>
 <20130807163236.0F17DE0090@blue.fi.intel.com>
 <20130807200032.GE26516@quack.suse.cz>
 <20130807202403.7BCEEE0090@blue.fi.intel.com>
 <20130807203650.GI26516@quack.suse.cz>
 <20130807213736.AC732E0090@blue.fi.intel.com>
Subject: Re: [PATCH 01/23] radix-tree: implement preload for multiple
 contiguous elements
Content-Transfer-Encoding: 7bit
Message-Id: <20130808084505.31EACE0090@blue.fi.intel.com>
Date: Thu,  8 Aug 2013 11:45:05 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@linux.intel.com>, Dave Hansen <dave@sr71.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Ning Qu <quning@google.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Kirill A. Shutemov wrote:
> In this case it should use 39 nodes, but it uses only 38. I can't understand why. :(

Okay, I've got it. We share one 2nd level node.

Patch is below. Please review.
