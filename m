Date: Sat, 7 Feb 2004 18:08:17 -0500
From: Ben Collins <bcollins@debian.org>
Subject: Re: 2.6.2-mm1 aka "Geriatric Wombat"
Message-ID: <20040207230817.GU1042@phunnypharm.org>
References: <fa.h1qu7q8.n6mopi@ifi.uio.no> <402240F9.3050607@gadsdon.giointernet.co.uk> <20040205182614.GG13075@kroah.com> <20040206144729.GJ1042@phunnypharm.org> <20040206182200.GE32116@kroah.com> <20040207172757.GQ1042@phunnypharm.org> <20040207191315.GC2581@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040207191315.GC2581@kroah.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Greg KH <greg@kroah.com>
Cc: Robert Gadsdon <robert@gadsdon.giointernet.co.uk>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > One thing I notice is that I am not checking the return value of
> > device_register(), however if that fails, the device shouldn't be in the
> > device list for the bus, correct?
> 
> That is correct.  I don't see the problem either in looking at your
> code...

Well, unless someone finds eveidence to the contrary, I'm going to
assume this isn't a bug in ieee1394 :)

-- 
Debian     - http://www.debian.org/
Linux 1394 - http://www.linux1394.org/
Subversion - http://subversion.tigris.org/
WatchGuard - http://www.watchguard.com/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
