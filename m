Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 219576B002E
	for <linux-mm@kvack.org>; Fri, 26 Jan 2018 21:50:06 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id 9so1489074otu.17
        for <linux-mm@kvack.org>; Fri, 26 Jan 2018 18:50:06 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o90sor3897988ota.333.2018.01.26.18.50.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jan 2018 18:50:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180125164750.GB31752@infradead.org>
References: <CAPcyv4gQNM9RbTbRWKnG6Vby_CW9CJ9EZTARsVNi=9cas7ZR2A@mail.gmail.com>
 <20180125072351.GA11093@infradead.org> <20180125160802.GD10706@ziepe.ca> <20180125164750.GB31752@infradead.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 26 Jan 2018 18:50:02 -0800
Message-ID: <CAPcyv4hi98RDD=F1rhumgCF+UiOisidmeAVrDePrTzF1ArXj4A@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Filesystem-DAX, page-pinning, and RDMA
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, lsf-pc@lists.linux-foundation.org, Michal Hocko <mhocko@kernel.org>, Linux MM <linux-mm@kvack.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-nvdimm@lists.01.org

On Thu, Jan 25, 2018 at 8:47 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Thu, Jan 25, 2018 at 09:08:02AM -0700, Jason Gunthorpe wrote:
>> On Wed, Jan 24, 2018 at 11:23:51PM -0800, Christoph Hellwig wrote:
>> > On Wed, Jan 24, 2018 at 07:56:02PM -0800, Dan Williams wrote:
>> > > Particular people that would be useful to have in attendance are
>> > > Michal Hocko, Christoph Hellwig, and Jason Gunthorpe (cc'd).
>> >
>> > I won't be able to make it - I'll have to do election work and
>> > count the ballots for our city council and mayor election.
>>
>> I also have a travel conflict for that week in April and cannot make
>> it.
>
> Are any of you going to be in the Bay Area in February for Usenix
> FAST / LinuxFAST?

I'll be around, but that said I still think it's worthwhile to have
this conversation at LSF/MM. While we have a plan for filesystem-dax
vs RDMA, there's still the open implications for the mm in other
scenarios. I see Michal has also proposed this topic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
