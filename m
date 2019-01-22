Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8F09D8E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 18:52:14 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id n39so420716qtn.18
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 15:52:14 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v10si1883875qto.109.2019.01.22.15.52.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 15:52:13 -0800 (PST)
Date: Tue, 22 Jan 2019 18:52:07 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [LSF/MM TOPIC] Page flags, can we free up space ?
Message-ID: <20190122235207.GC4747@redhat.com>
References: <20190122201744.GA3939@redhat.com>
 <87tvi074gg.fsf@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <87tvi074gg.fsf@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jan 22, 2019 at 01:44:15PM -0800, Andi Kleen wrote:
> Jerome Glisse <jglisse@redhat.com> writes:
> >
> > Right now this is more a temptative ie i do not know if i will succeed,
> > in any case i can report on failure or success and discuss my finding to
> > get people opinions on the matter.
> 
> I would just stop putting node/zone number into the flags. These
> could be all handled with a small perfect hash table, like the original
> x86_64 port did, which should be quite cheap to look up.
> Then there should be enough bits for everyone again.

Definitly something i will look into, i was scare to remove those.

Cheers,
Jérôme
