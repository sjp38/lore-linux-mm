Date: Tue, 26 Sep 2000 17:04:06 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: the new VMt
Message-ID: <20000926170406.C1343@redhat.com>
References: <20000925191829.A14612@pcep-jamie.cern.ch> <20000925115139.A14999@hq.fsmlabs.com> <20000925200454.A14728@pcep-jamie.cern.ch> <20000925121315.A15966@hq.fsmlabs.com> <20000925192453.R2615@redhat.com> <20000925123456.A16612@hq.fsmlabs.com> <20000925202549.V2615@redhat.com> <20000925140419.A18243@hq.fsmlabs.com> <20000925171411.A2397@codepoet.org> <20000926091744.A25214@hq.fsmlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000926091744.A25214@hq.fsmlabs.com>; from yodaiken@fsmlabs.com on Tue, Sep 26, 2000 at 09:17:44AM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: yodaiken@fsmlabs.com
Cc: MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Sep 26, 2000 at 09:17:44AM -0600, yodaiken@fsmlabs.com wrote:

> Operating systems cannot make more memory appear by magic.
> The question is really about the best strategy for dealing with low memory. In my
> opinion, the OS should not try to out-think physical limitations. Instead, the OS 
> should take as little space as possible and provide the ability for user level 
> clever management of space. In a truly embedded system, there can easily be a user level
> root process that watches memory usage and prevents DOS attacks -- if the OS provides
> settable enforced quotas etc. 

Agreed, absolutely.  The beancounter is one approach to those quotas,
and has the advantage of allowing per-user as well as per-process
quotas.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
