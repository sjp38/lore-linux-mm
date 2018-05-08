Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6EFFF6B0003
	for <linux-mm@kvack.org>; Tue,  8 May 2018 04:28:20 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id c21so15603442qkg.19
        for <linux-mm@kvack.org>; Tue, 08 May 2018 01:28:20 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id f84si966099qkf.9.2018.05.08.01.28.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 May 2018 01:28:19 -0700 (PDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <e2aa9491-c1e3-4ae1-1ab2-589a6642a24a@infradead.org>
References: <e2aa9491-c1e3-4ae1-1ab2-589a6642a24a@infradead.org> <20180507231506.4891-1-mcgrof@kernel.org>
Subject: Re: [PATCH] mm: expland documentation over __read_mostly
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <32207.1525768094.1@warthog.procyon.org.uk>
Date: Tue, 08 May 2018 09:28:14 +0100
Message-ID: <32208.1525768094@warthog.procyon.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: dhowells@redhat.com, "Luis R. Rodriguez" <mcgrof@kernel.org>, tglx@linutronix.de, arnd@arndb.de, cl@linux.com, keescook@chromium.org, luto@amacapital.net, longman@redhat.com, viro@zeniv.linux.org.uk, willy@infradead.org, ebiederm@xmission.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Randy Dunlap <rdunlap@infradead.org> wrote:

> > + * execute a critial path. We should be mindful and selective if its use.
> 
>                                                                  of its use.

                                                                   in its use.

David
