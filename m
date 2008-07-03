From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Thu, 3 Jul 2008 23:52:33 +0200
References: <20080703020236.adaa51fa.akpm@linux-foundation.org> <200807032342.01292.rjw@sisk.pl> <486D47F1.4080406@infradead.org>
In-Reply-To: <486D47F1.4080406@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200807032352.35056.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: Jeff Garzik <jeff@garzik.org>, Theodore Tso <tytso@mit.edu>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thursday, 3 of July 2008, David Woodhouse wrote:
> Rafael J. Wysocki wrote:
> > Still, maybe we can add some kbuild magic to build the blobs along with
> > their modules and to install them under /lib/firmware (by default) when the
> > modules are installed in /lib/modules/... ?
> 
> Something like appending this to Makefile?
> 
> firmware_and_modules_install: firmware_install modules_install
> 
> (I'm still wondering if we should make 'firmware_install' install to 
> /lib/firmware by default, instead of into the build tree as 
> 'headers_install' does. The Aunt Tillie answer would definitely be 
> 'yes', although that means it requires root privs; like modules_install 
> does.)

I would prefer 'make firmware_install' to just copy the blobs into specific
location in analogy with 'make modules_install', so that you can build the
blobs as a normal user (for example, on an NFS server) and then put them
into the right place as root (for example, on an NFS client that has no write
privilege on the server).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
