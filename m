Subject: Re: lsattr: Inappropriate ioctl for device While reading flags!!!
References: <20040723190555.GB16956@sgi.com>
	<200407270729.45116.aroop@poornam.com>
	<20040727020338.GB23967@sgi.com>
	<200407270741.44003.aroop@poornam.com>
From: Philippe Troin <phil@fifi.org>
Date: 26 Jul 2004 23:40:57 -0700
In-Reply-To: <200407270741.44003.aroop@poornam.com>
Message-ID: <874qnueyva.fsf@ceramic.fifi.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Aroop MP <aroop@poornam.com>
Cc: Dimitri Sivanich <sivanich@sgi.com>, manfred@colorfullife.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lse-tech@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Aroop MP <aroop@poornam.com> writes:

> Hi,
> 
> Thanks for your quick reply. When i check lsattr of the file 
> /usr/local/cpanel/3rdparty/etc/php.ini  i got the following error.
> ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> Server[~]# lsattr /usr/local/cpanel/3rdparty/etc/php.ini
> lsattr: Inappropriate ioctl for device While reading flags on 
> /usr/local/cpanel/3rdparty/etc/php.ini
> Server[~]#
> ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> 
> Please get back to me if you need any more  info. regarding this.

Because /usr/local/cpanel/3rdparty/etc/php.ini is not on an ext[23]
filesystem? Remote mounting via NFS, or your favorite network fs does
not count as ext[23].

Phil.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
