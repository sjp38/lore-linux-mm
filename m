Date: Tue, 26 Sep 2000 18:08:20 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: the new VMt
Message-ID: <20000926180820.E1343@redhat.com>
References: <20000925200454.A14728@pcep-jamie.cern.ch> <20000925121315.A15966@hq.fsmlabs.com> <20000925192453.R2615@redhat.com> <20000925123456.A16612@hq.fsmlabs.com> <20000925202549.V2615@redhat.com> <20000925140419.A18243@hq.fsmlabs.com> <20000925171411.A2397@codepoet.org> <20000926091744.A25214@hq.fsmlabs.com> <20000926170406.C1343@redhat.com> <20000926110247.A4698@codepoet.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000926110247.A4698@codepoet.org>; from andersen@codepoet.org on Tue, Sep 26, 2000 at 11:02:48AM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>, yodaiken@fsmlabs.com, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Sep 26, 2000 at 11:02:48AM -0600, Erik Andersen wrote:

> Another approach would be to let user space turn off overcommit.  

No.  Overcommit only applies to pageable memory.  Beancounter is
really needed for non-pageable resources such as page tables and
mlock()ed pages.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
