Date: Wed, 27 Sep 2000 20:55:33 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
Message-ID: <20000927205533.A17500@athlon.random>
References: <20000925205457.Y2615@redhat.com> <qwwd7hriqxs.fsf@sap.com> <20000926160554.B13832@athlon.random> <qww7l7z86qo.fsf@sap.com> <20000926191027.A16692@athlon.random> <qwwn1gu6yps.fsf@sap.com> <20000927155608.D27898@athlon.random> <qwwsnql6aet.fsf@sap.com> <20000927194200.A15943@athlon.random> <20000927122544.B10583@codepoet.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000927122544.B10583@codepoet.org>; from andersen@codepoet.org on Wed, Sep 27, 2000 at 12:25:44PM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 27, 2000 at 12:25:44PM -0600, Erik Andersen wrote:
> Or sysinfo(2).  Same thing...

sysinfo structure doesn't export the number of active pages in the system.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
