From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14315.42764.144468.501249@dukat.scot.redhat.com>
Date: Fri, 24 Sep 1999 17:30:04 +0100 (BST)
Subject: Re: syslinux-1.43 bug [and possible PATCH]
In-Reply-To: <37EB3C86.F17CC25A@transmeta.com>
References: <199909232109.OAA13866@google.engr.sgi.com>
	<99Sep24.094756bst.66313@gateway.ukaea.org.uk>
	<37EB3C86.F17CC25A@transmeta.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "H. Peter Anvin" <hpa@transmeta.com>
Cc: Neil Conway <nconway.list@UKAEA.ORG.UK>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, syslinux@linux.kernel.org, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi,

In article <37EB3C86.F17CC25A@transmeta.com>, "H. Peter Anvin"
<hpa@transmeta.com> writes:

> Neil Conway wrote:
>> My "easy" fix was to pull out a DIMM from each of our machines, leaving
>> 3x256 :-)  Not elegant, but fast!

> As already said, get SYSLINUX 1.44 or later...

Which works nicely --- thanks Peter.  The current Red Hat lorax
snapshots use the later syslinux and for the first time they boot
without messing about with kernel mem= parameters on the large-mem box
here.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
