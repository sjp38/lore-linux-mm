Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id DC8B36B0027
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 11:00:31 -0400 (EDT)
Date: Fri, 15 Mar 2013 11:00:22 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: Inactive memory keep growing and how to release it?
Message-ID: <20130315150022.GD7403@thunk.org>
References: <CAAO_Xo7sEH5W_9xoOjax8ynyjLCx7GBpse+EU0mF=9mEBFhrgw@mail.gmail.com>
 <20130314101403.GB11636@dhcp22.suse.cz>
 <5142DEC5.7010206@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5142DEC5.7010206@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, Lenky Gao <lenky.gao@gmail.com>, Greg KH <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Mar 15, 2013 at 04:41:41PM +0800, Simon Jeons wrote:
> >This is really an old kernel and also a distribution one which might
> >contain a lot of patches on top of the core kernel. I would suggest to
> >contact Redhat or try to reproduce the issue with the vanilla and
> 
> What's the meaning of vanilla?

Vanilla means an up-to-date (i.e., non-prehistoric) kernel from
kernel.org, without any "Value Added" patches from a distribution.

See: https://www.kernel.org/

Regards,

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
