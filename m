Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id CAEC28E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 16:44:17 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id s71so22363pfi.22
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 13:44:17 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id f5si11526028pfn.259.2019.01.22.13.44.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 13:44:16 -0800 (PST)
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [LSF/MM TOPIC] Page flags, can we free up space ?
References: <20190122201744.GA3939@redhat.com>
Date: Tue, 22 Jan 2019 13:44:15 -0800
In-Reply-To: <20190122201744.GA3939@redhat.com> (Jerome Glisse's message of
	"Tue, 22 Jan 2019 15:17:44 -0500")
Message-ID: <87tvi074gg.fsf@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Jerome Glisse <jglisse@redhat.com> writes:
>
> Right now this is more a temptative ie i do not know if i will succeed,
> in any case i can report on failure or success and discuss my finding to
> get people opinions on the matter.

I would just stop putting node/zone number into the flags. These
could be all handled with a small perfect hash table, like the original
x86_64 port did, which should be quite cheap to look up.
Then there should be enough bits for everyone again.

-Andi
