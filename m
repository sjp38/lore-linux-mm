Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id BF4B06B0271
	for <linux-mm@kvack.org>; Tue,  8 May 2018 07:23:45 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id a12-v6so3124672pgu.20
        for <linux-mm@kvack.org>; Tue, 08 May 2018 04:23:45 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 9-v6si17726231ple.63.2018.05.08.04.23.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 08 May 2018 04:23:44 -0700 (PDT)
Date: Tue, 8 May 2018 04:23:21 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: expland documentation over __read_mostly
Message-ID: <20180508112321.GA30120@bombadil.infradead.org>
References: <e2aa9491-c1e3-4ae1-1ab2-589a6642a24a@infradead.org>
 <20180507231506.4891-1-mcgrof@kernel.org>
 <32208.1525768094@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <32208.1525768094@warthog.procyon.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Randy Dunlap <rdunlap@infradead.org>, "Luis R. Rodriguez" <mcgrof@kernel.org>, tglx@linutronix.de, arnd@arndb.de, cl@linux.com, keescook@chromium.org, luto@amacapital.net, longman@redhat.com, viro@zeniv.linux.org.uk, ebiederm@xmission.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, May 08, 2018 at 09:28:14AM +0100, David Howells wrote:
> Randy Dunlap <rdunlap@infradead.org> wrote:
> 
> > > + * execute a critial path. We should be mindful and selective if its use.
> > 
> >                                                                  of its use.
> 
>                                                                    in its use.
								     with its use.

Nah, just kidding.  Let's go with "in".
