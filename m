Subject: xmm2 - monitor Linux MM active/inactive lists graphically
Reply-To: zlatko.calusic@iskon.hr
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
Date: 24 Oct 2001 12:42:26 +0200
Message-ID: <8766959v59.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

New version is out and can be found at the same URL:

<URL:http://linux.inet.hr/>

As Linus' MM lost inactive dirty/clean lists in favour of just one
inactive list, the application needed to be modified to support that.

You can still continue to use the older one for kernels <= 2.4.9
and/or Alan's (-ac) kernels, which continued to use older Rik's VM
system.

Enjoy and, as usual, all comments welcome!
-- 
Zlatko

P.S. BTW, 2.4.13 still has very unoptimal writeout performance and
     andrea@suse.de is redirected to /dev/null. <g>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
