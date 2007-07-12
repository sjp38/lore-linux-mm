From: Daniel Phillips <phillips@phunq.net>
Subject: Re: [PATCH RFC] extent mapped page cache
Date: Thu, 12 Jul 2007 00:00:28 -0700
References: <20070710210326.GA29963@think.oraclecorp.com>
In-Reply-To: <20070710210326.GA29963@think.oraclecorp.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200707120000.28501.phillips@phunq.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tuesday 10 July 2007 14:03, Chris Mason wrote:
> This patch aims to demonstrate one way to replace buffer heads with a
> few extent trees...

Hi Chris,

Quite terse commentary on algorithms and data structures, but I suppose
that is not a problem because Jon has a whole week to reverse engineer
it for us.

What did you have in mind for subpages?

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
