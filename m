Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9D2346B027E
	for <linux-mm@kvack.org>; Tue,  8 May 2018 08:54:18 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id b202so23484849qkc.6
        for <linux-mm@kvack.org>; Tue, 08 May 2018 05:54:18 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id t186si1527206qkb.283.2018.05.08.05.54.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 May 2018 05:54:18 -0700 (PDT)
Date: Tue, 8 May 2018 07:54:15 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: expland documentation over __read_mostly
In-Reply-To: <20180507231506.4891-1-mcgrof@kernel.org>
Message-ID: <alpine.DEB.2.21.1805080753590.1849@nuc-kabylake>
References: <20180507231506.4891-1-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: tglx@linutronix.de, arnd@arndb.de, keescook@chromium.org, luto@amacapital.net, longman@redhat.com, viro@zeniv.linux.org.uk, willy@infradead.org, ebiederm@xmission.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 7 May 2018, Luis R. Rodriguez wrote:

> __read_mostly can easily be misused by folks, its not meant for
> just read-only data. There are performance reasons for using it, but
> we also don't provide any guidance about its use. Provide a bit more
> guidance over it use.

Acked-by: Christoph Lameter <cl@linux.com>
