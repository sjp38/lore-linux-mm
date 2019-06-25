Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D24FC48BD6
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 19:52:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50BE82086D
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 19:52:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="cg40kmVD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50BE82086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C92396B0005; Tue, 25 Jun 2019 15:52:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C1B588E0003; Tue, 25 Jun 2019 15:52:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ABC308E0002; Tue, 25 Jun 2019 15:52:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7CC286B0005
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 15:52:30 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id f36so9639287otf.7
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 12:52:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=w0iye/3d1d43WiqVq+yINWIQnPqAw8A16FUwAjTLITU=;
        b=GPk9h/wONPowJDA3Ko8/88aqo4OxvINRpTsHE84OUODPZ2tzPNnqyNQAGvtMesIo17
         alq3GIfi7stl9E3AvKwSY4oH56xLXFm61L/KTinu6F8zdYz4rm7LYLzMyRRaQI1KtMmD
         1EqXmHsdUq5KnX2bKiTkX6Nmyczom0ez77J9Q/RQhaHV0kwBIoZi9+NPl8ymCZMwi1zt
         X6cmt4MU6SBSAGv4mmnsrYMJWuhe5FbVFKbSZPJCoJt1hOBXcApbuRCflL/sezFUy7x8
         eWUv4z05iTvyyPufnTAE9Kci9+yP1JTmK1gMeiWkz8hfscheSlv4w+3WpbROpdMzMw8Q
         LEAg==
X-Gm-Message-State: APjAAAVPrEt23PflrxSJZgcJW/mO6nSaVFtMlu/oGjD6b8iVS3EBgEQI
	qG5gl7fYhNEpWCznrjuAkjbxilZkfTZ6FnD+u3Dar7OzXv9jO+E5cWLA6ortW7LLnpd31Qz0AkO
	sJlZE0O+Pq2rZkupjzO0JNqbteGr6PV1AibGBeYFjS0w+802hTneAqjFBxW8Ot42IyQ==
X-Received: by 2002:aca:e4ca:: with SMTP id b193mr4729213oih.126.1561492350113;
        Tue, 25 Jun 2019 12:52:30 -0700 (PDT)
X-Received: by 2002:aca:e4ca:: with SMTP id b193mr4729167oih.126.1561492349243;
        Tue, 25 Jun 2019 12:52:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561492349; cv=none;
        d=google.com; s=arc-20160816;
        b=nRhmWXwdhB9u9QT+znsZkwO1t5AxZfYBqDSXmVo1D9+MH3Ize5xOL+6bHOWrG0vkfB
         fJEVdoInYzES7AC7UwIdqnRlyfbiFnHvXpW8vI+94vVAQj2vO+psVd5Y+Nw5Xs6ZNK3B
         XyThgsuzc2etO9LEcX0WZp0Ejl5+/BmSjKiCjBvj3iCpSQeDC8TrHTDvkg7bK47M9GUs
         i0b0gSu5b5EraAsa0WtTdkMdKpYFCTD13iOZiIibh0/IksGaV57FQGt5uRN3kNiZxtVT
         yRM1t80NHboq6SyylyUmOmA9lxj2tss8lRB7DQZ9RAN7FJMNKPXY+ObLtNCiQandJU+f
         ZZlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=w0iye/3d1d43WiqVq+yINWIQnPqAw8A16FUwAjTLITU=;
        b=jF40IeiXPTpnxWWIeaRIlX89XGZ7Iii+r+Ud323gQ2JoXeUR9/I+86KyiVVD51WUnM
         +c77qhdHvWt8A9Aam93P6iXYBH50nq60bUdeP6AglTcMckYzZ/fHLfy1B4eoIDq9kwkI
         tqYIGuLmvKs03KECfoZQV3Ea46bFkOVE5nYdHsIpKq3lmrItbhkploCSnnU11Nuvr6Ro
         lbi9FfJCWczXKT+6tdBOtI9LuvgtWDpxYnIl7Hlol/bqtxGK5ZzUthUN+r5HeKZE7qoR
         NAaYWIxDZUijpoQSg4ISa62xXH/dapmIQ4cgjDMLUbwUT9EWPTmwcVATWWW2nQNQfS4q
         LpyA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=cg40kmVD;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j24sor8457478otk.32.2019.06.25.12.52.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Jun 2019 12:52:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=cg40kmVD;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=w0iye/3d1d43WiqVq+yINWIQnPqAw8A16FUwAjTLITU=;
        b=cg40kmVDe098Yeal1OpwCn3OtKBjzRnBRkGsDiRkJlBZmoYI19FP8EGzmZENBKS9gc
         y85l2sQkHTXgqXraL4kaAGyPSS89BlMic0a5IYD4ijt8AaGI5dAMpm1LqTsvqtZ0PA18
         /sFXK4G4VbfJsBTSuI7jnUNqry2IT3CR4rWFZDFAIwwgF0wpO56iBYn1OrWh8zMn5H5U
         UiXxOJDTdDUZ1sp/qT4gDr5qxfq60VgObAV3QcEkH8aWy3k9rRcTQ+1xwDIMTbjb/rOl
         vLBtj451wwdwT3Iv/y3LeY44bWSWgm5KwxP2Hkh4f45wvrSWUrzPcQdtg3gHbAGRQLJ3
         R1iQ==
X-Google-Smtp-Source: APXvYqx9tkQWIJH6qfCTM4r93Fn0JkGxBFjGh9k1TjumYyf0PnXcUjYDBWeUS/klLXmbZuWZeGlEsSD0mVmlPe4JDBw=
X-Received: by 2002:a9d:7b48:: with SMTP id f8mr50775oto.207.1561492348979;
 Tue, 25 Jun 2019 12:52:28 -0700 (PDT)
MIME-Version: 1.0
References: <20190613094326.24093-1-hch@lst.de> <20190613094326.24093-6-hch@lst.de>
 <20190620191733.GH12083@dhcp22.suse.cz> <CAPcyv4h9+Ha4FVrvDAe-YAr1wBOjc4yi7CAzVuASv=JCxPcFaw@mail.gmail.com>
 <20190625072317.GC30350@lst.de> <20190625150053.GJ11400@dhcp22.suse.cz>
 <CAPcyv4j1e5dbBHnc+wmtsNUyFbMK_98WxHNwuD_Vxo4dX9Ce=Q@mail.gmail.com> <20190625190038.GK11400@dhcp22.suse.cz>
In-Reply-To: <20190625190038.GK11400@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 25 Jun 2019 12:52:18 -0700
Message-ID: <CAPcyv4hU13v7dSQpF0WTQTxQM3L3UsHMUhsFMVz7i4UGLoM89g@mail.gmail.com>
Subject: Re: [PATCH 05/22] mm: export alloc_pages_vma
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>, Linux MM <linux-mm@kvack.org>, 
	nouveau@lists.freedesktop.org, 
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	linux-pci@vger.kernel.org, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 25, 2019 at 12:01 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 25-06-19 11:03:53, Dan Williams wrote:
> > On Tue, Jun 25, 2019 at 8:01 AM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Tue 25-06-19 09:23:17, Christoph Hellwig wrote:
> > > > On Mon, Jun 24, 2019 at 11:24:48AM -0700, Dan Williams wrote:
> > > > > I asked for this simply because it was not exported historically. In
> > > > > general I want to establish explicit export-type criteria so the
> > > > > community can spend less time debating when to use EXPORT_SYMBOL_GPL
> > > > > [1].
> > > > >
> > > > > The thought in this instance is that it is not historically exported
> > > > > to modules and it is safer from a maintenance perspective to start
> > > > > with GPL-only for new symbols in case we don't want to maintain that
> > > > > interface long-term for out-of-tree modules.
> > > > >
> > > > > Yes, we always reserve the right to remove / change interfaces
> > > > > regardless of the export type, but history has shown that external
> > > > > pressure to keep an interface stable (contrary to
> > > > > Documentation/process/stable-api-nonsense.rst) tends to be less for
> > > > > GPL-only exports.
> > > >
> > > > Fully agreed.  In the end the decision is with the MM maintainers,
> > > > though, although I'd prefer to keep it as in this series.
> > >
> > > I am sorry but I am not really convinced by the above reasoning wrt. to
> > > the allocator API and it has been a subject of many changes over time. I
> > > do not remember a single case where we would be bending the allocator
> > > API because of external modules and I am pretty sure we will push back
> > > heavily if that was the case in the future.
> >
> > This seems to say that you have no direct experience of dealing with
> > changing symbols that that a prominent out-of-tree module needs? GPU
> > drivers and the core-mm are on a path to increase their cooperation on
> > memory management mechanisms over time, and symbol export changes for
> > out-of-tree GPU drivers have been a significant source of friction in
> > the past.
>
> I have an experience e.g. to rework semantic of some gfp flags and that is
> something that users usualy get wrong and never heard that an out of
> tree code would insist on an old semantic and pushing us to the corner.
>
> > > So in this particular case I would go with consistency and export the
> > > same way we do with other functions. Also we do not want people to
> > > reinvent this API and screw that like we have seen in other cases when
> > > external modules try reimplement core functionality themselves.
> >
> > Consistency is a weak argument when the cost to the upstream community
> > is negligible. If the same functionality was available via another /
> > already exported interface *that* would be an argument to maintain the
> > existing export policy. "Consistency" in and of itself is not a
> > precedent we can use more widely in default export-type decisions.
> >
> > Effectively I'm arguing EXPORT_SYMBOL_GPL by default with a later
> > decision to drop the _GPL. Similar to how we are careful to mark sysfs
> > interfaces in Documentation/ABI/ that we are not fully committed to
> > maintaining over time, or are otherwise so new that there is not yet a
> > good read on whether they can be made permanent.
>
> Documentation/process/stable-api-nonsense.rst

That document has failed to preclude symbol export fights in the past
and there is a reasonable argument to try not to retract functionality
that had been previously exported regardless of that document.

> Really. If you want to play with GPL vs. EXPORT_SYMBOL else this is up
> to you but I do not see any technical argument to make this particular
> interface to the page allocator any different from all others that are
> exported to modules.

I'm failing to find any practical substance to your argument, but in
the end I agree with Chrishoph, it's up to MM maintainers.

