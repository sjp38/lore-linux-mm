Date: Thu, 14 Nov 2002 13:31:54 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [patch] remove hugetlb syscalls
Message-ID: <20021114213154.GN23425@holomorphy.com>
References: <20021113184555.B10889@redhat.com> <20021114203035.GF22031@holomorphy.com> <20021114154809.D20258@redhat.com> <20021114210220.GM23425@holomorphy.com> <20021114161134.E20258@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20021114161134.E20258@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 14, 2002 at 04:11:34PM -0500, Benjamin LaHaise wrote:
> Oracle does not run as root, so they can't even use the syscalls 
> directly.  At least with hugetlbfs we can chmod the filesystem to be 
> owned by the oracle user.

Okay, the advantage with respect to permissions is clear; now there is
a correction to the permissions checking I should do, as CAP_IPC_LOCK
is currently checked in ->f_ops->mmap(), but the permissions are
enforcible by means of ordinary vfs permissions, and so it's redundant.


Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
