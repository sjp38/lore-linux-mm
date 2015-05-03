Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 59D3A6B0038
	for <linux-mm@kvack.org>; Sat,  2 May 2015 22:21:27 -0400 (EDT)
Received: by qcvz3 with SMTP id z3so9234994qcv.0
        for <linux-mm@kvack.org>; Sat, 02 May 2015 19:21:27 -0700 (PDT)
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [2001:4b98:c:538::195])
        by mx.google.com with ESMTPS id b123si9194014qka.20.2015.05.02.19.21.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 02 May 2015 19:21:26 -0700 (PDT)
Date: Sat, 2 May 2015 19:21:17 -0700
From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [CONFIG_MULTIUSER] init: error.c:320: Assertion failed in
 nih_error_get: CURRENT_CONTEXT->error != NULL
Message-ID: <20150503022117.GA25173@x>
References: <20150428004320.GA19623@wfg-t540p.sh.intel.com>
 <20150502231828.GA25301@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150502231828.GA25301@wfg-t540p.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Iulia Manda <iulia.manda21@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, LKP <lkp@01.org>, linux-kernel@vger.kernel.org

On Sun, May 03, 2015 at 07:18:28AM +0800, Fengguang Wu wrote:
> Hi Iulia,
> 
> FYI, there are Ubuntu init error messages when CONFIG_MULTIUSER=n.
> Since it's not embedded system and hence the target user of
> CONFIG_MULTIUSER=n, it might be fine..

I would expect a non-trivial amount of work required to make a standard
distribution boot with CONFIG_MULTIUSER=n.  Anything attempting to set
the user ID or group ID will fail, such as su, start-stop-daemon
--chuid, or systemd's daemon launching code.

So I'd suggest that this is an expected failure; allnoconfig or
tinyconfig would already not be expected to boot unmodified Ubuntu.

- Josh triplett

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
