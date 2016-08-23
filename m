Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DDAF66B0069
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 01:58:25 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 63so239423472pfx.0
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 22:58:25 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id g71si2174937pfk.206.2016.08.22.22.58.24
        for <linux-mm@kvack.org>;
        Mon, 22 Aug 2016 22:58:25 -0700 (PDT)
Date: Tue, 23 Aug 2016 14:55:50 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [Revised document] Crossrelease lockdep
Message-ID: <20160823055550.GY2279@X58A-UD3R>
References: <1467883803-29132-1-git-send-email-byungchul.park@lge.com>
 <20160819123959.GW2279@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160819123959.GW2279@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, npiggin@kernel.dk, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Please let me know your opinions. I'm planning to post next spin if you
agree with at least the concept. I omitted many things about e.g.
synchronization, set theory and so on, since I don't want it to be too
lengthy document, so focused on only essential thingy. Please let me know
if you think there are logical problems in the document. I might be able
to answer it. It would be appreciated if you check the document.

Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
