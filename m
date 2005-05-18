Date: Wed, 18 May 2005 14:56:44 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: page flags ?
Message-Id: <20050518145644.717afc21.akpm@osdl.org>
In-Reply-To: <1116450834.26913.1293.camel@dyn318077bld.beaverton.ibm.com>
References: <1116450834.26913.1293.camel@dyn318077bld.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Badari Pulavarty <pbadari@us.ibm.com> wrote:
>
> Does anyone know what this page-flag is used for ? I see some
> references to this in AFS. 
> 
> Is it possible for me to use this for my own use in ext3 ? 
> (like delayed allocations ?) Any generic routines/VM stuff
> expects me to use this only for a specific purpose ?
> 
> #define PG_fs_misc               9      /* Filesystem specific bit */
> 

It's identical to PG_checked, added by David Howells'
provide-a-filesystem-specific-syncable-page-bit.patch

IIRC we decided to expand the definition of PG_checked to mean
"a_ops-private, fs-defined page flag".  I guess if/when that patch is
merged we'll do a kernel-wide s/PG_checked/PG_fs_misc/.

And ext3 is already using that flag.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
