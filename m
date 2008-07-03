Message-ID: <486D4A92.2060004@infradead.org>
Date: Thu, 03 Jul 2008 22:54:26 +0100
From: David Woodhouse <dwmw2@infradead.org>
MIME-Version: 1.0
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
References: <20080703020236.adaa51fa.akpm@linux-foundation.org> <200807032342.01292.rjw@sisk.pl> <486D47F1.4080406@infradead.org> <200807032352.35056.rjw@sisk.pl>
In-Reply-To: <200807032352.35056.rjw@sisk.pl>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Jeff Garzik <jeff@garzik.org>, Theodore Tso <tytso@mit.edu>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rafael J. Wysocki wrote:
> On Thursday, 3 of July 2008, David Woodhouse wrote:
>> Rafael J. Wysocki wrote:
>>> Still, maybe we can add some kbuild magic to build the blobs along with
>>> their modules and to install them under /lib/firmware (by default) when the
>>> modules are installed in /lib/modules/... ?
>> Something like appending this to Makefile?
>>
>> firmware_and_modules_install: firmware_install modules_install
>>
>> (I'm still wondering if we should make 'firmware_install' install to 
>> /lib/firmware by default, instead of into the build tree as 
>> 'headers_install' does. The Aunt Tillie answer would definitely be 
>> 'yes', although that means it requires root privs; like modules_install 
>> does.)
> 
> I would prefer 'make firmware_install' to just copy the blobs into specific
> location in analogy with 'make modules_install', so that you can build the
> blobs as a normal user (for example, on an NFS server) and then put them
> into the right place as root (for example, on an NFS client that has no write
> privilege on the server).

Not entirely sure which you mean. You _can't_ run 'make modules_install' 
as a normal user, unless you override $(INSTALL_MOD_PATH) on the command 
line.

Do you want 'make firmware_install' to be the same? It isn't at the 
moment -- it installs to a subdirectory of the kernel build tree, like 
'make headers_install' does. But I'm not sure which is better.

-- 
dwmw2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
