Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D04D86B026E
	for <linux-mm@kvack.org>; Tue, 22 May 2018 17:42:11 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id l85-v6so11766348pfb.18
        for <linux-mm@kvack.org>; Tue, 22 May 2018 14:42:11 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r3-v6si19399101pli.324.2018.05.22.14.42.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 14:42:10 -0700 (PDT)
Received: from akpm3.svl.corp.google.com (unknown [104.133.9.71])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 73306949
	for <linux-mm@kvack.org>; Tue, 22 May 2018 21:41:59 +0000 (UTC)
Date: Tue, 22 May 2018 14:41:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 199763] System is unresponsive, or completely frozen on
 high memory usage
Message-Id: <20180522144158.c344458466ca9d2a450197f2@linux-foundation.org>
In-Reply-To: <bug-199763-27-KF5s1fxs8M@https.bugzilla.kernel.org/>
References: <bug-199763-27@https.bugzilla.kernel.org/>
	<bug-199763-27-KF5s1fxs8M@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

On Mon, 21 May 2018 23:30:03 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=199763
> 

And https://bugzilla.kernel.org/show_bug.cgi?id=196729

Basically, we suck.  And have done for 11 years.
