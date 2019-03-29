Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDAD8C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 02:25:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E0E12173C
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 02:25:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E0E12173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F9036B0007; Thu, 28 Mar 2019 22:25:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15A1E6B0008; Thu, 28 Mar 2019 22:25:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3C716B000C; Thu, 28 Mar 2019 22:25:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id CEA286B0007
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 22:25:24 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id s70so586050qka.1
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 19:25:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=7a9HpnY7wyUsYzddfkMhxIjKLRpCtSgSSRp19WkzLFM=;
        b=seFXFIirhScc+eaGADnPeEx2h6Iee9KKFDajKePz0UQZh1WrX6b2jpz7LS+LlkffNR
         KDvsln5gKZQfMz/B8kzRclzvH3AJ/6gwoNtEh8eQZClZs/tRr8i5Oi9lXqYAbXXx7woY
         ynGQKNW+NPvkQ5RMXMjKAtOiKJO86IYAISfB3RhazHuQcOqoV5obkiI2ytUXLPSh/frg
         xU0m39kJ7ynbhLX7YiE6Q5MqwDDSNMXxywt7ThmOnaOHxKJGGoIYnnQPpF7EetwGU9V6
         g05Y+CudvWo75qFqQLtFmi/uVCQeUFSRMv7iTWbgPs3b5E1sJkpTrc85sgAbLablv42I
         Oufw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU2CUfQMushyb/706UTOOffhCsS1UeK/Rm0jGaHpAZzQBqv7Z3p
	OqHk9LGpUEv9W91DyTYGzZjK7v3dq171ApYcrrlsGJpLf9dpsFvEA2V5LwJpSQFK0L29DSC7r30
	vedlfhAt3t4R836ZBnS6Unl5ZWcGFU4RfnECtgjO8oUBT9J/44UalXJp918EmhjgDTQ==
X-Received: by 2002:ac8:1846:: with SMTP id n6mr39803385qtk.262.1553826324599;
        Thu, 28 Mar 2019 19:25:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwXVDQ85h11p4c08x7B9XVcL3XDn2UT//EnE9IoMItHfGlK/+EgfDCS21Mwd/QiKn1mQPB5
X-Received: by 2002:ac8:1846:: with SMTP id n6mr39803357qtk.262.1553826323780;
        Thu, 28 Mar 2019 19:25:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553826323; cv=none;
        d=google.com; s=arc-20160816;
        b=baVvZzYchvQ7fkPdJQKGMT6nz1NuMIXY7XtnOJxNDUVOXe0mXp+rAXvpKKnMHncy1A
         Hqhl5dP/IcUjRcbpQN+Gv4fF1WGtmmEsPSVuHzAF5gQ5VcgKfOvhBegNYM4hh9/L2/Wi
         RbXSBPl2MVNZC/R4A197Egs/698bu/BHVv3hL5px0TDgWyVXsqB4K/1rpMGCUMtb0XG2
         X22kNQGE8KYpaLfEvkDNYe7aNvcvtzvI0U1/r9m/zR2zyr0NROFVaiLKuTpPwUP4CPEP
         2QWb2MH0kGs+zjo/w2tQxOOVoFnHMH0FJ6fYW+UKFY4G8w37LxCbs7FP+Z0qgmTQtNOS
         heXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=7a9HpnY7wyUsYzddfkMhxIjKLRpCtSgSSRp19WkzLFM=;
        b=HfRZSiKtvCq+jSom4ZXf2/a8Av0ETTcZMGY+8WXjAvtYa4yd+4fhrTlX/KNzBy7bUz
         /JuFRg6Z3rnDsFTWPqMl+1XTtkz7jgbH8LiO0CX6jRE3kROrBk9WsSl2PvLUBPIJcNPC
         qy1/zq/kWimrwZm1dfixWOPNW9Po5CvpMRoLezo7Uwt8HNYVeUlNxJoovmK7LtaFHkeA
         IlY2C+xVZtlsnHW9v9H/t2bItHZFvtxUKDAdf17VS2TTHxTHiPpaqnmVwudUtlTAGm80
         E9gYLqB4HJSnMFlQnISxFjX8BejniGhBOM5RZxrmQvIv7WuyxmaubpaIMB1nWxZViYuu
         d5DQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w14si349285qkf.159.2019.03.28.19.25.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 19:25:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id ECE5E88306;
	Fri, 29 Mar 2019 02:25:22 +0000 (UTC)
Received: from redhat.com (ovpn-121-118.rdu2.redhat.com [10.10.121.118])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 00C1C60851;
	Fri, 29 Mar 2019 02:25:21 +0000 (UTC)
Date: Thu, 28 Mar 2019 22:25:19 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Ira Weiny <ira.weiny@intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v2 02/11] mm/hmm: use reference counting for HMM struct v2
Message-ID: <20190329022519.GJ16680@redhat.com>
References: <20190328110719.GA31324@iweiny-DESK2.sc.intel.com>
 <20190328191122.GA5740@redhat.com>
 <c8fd897f-b9d3-a77b-9898-78e20221ba44@nvidia.com>
 <20190328212145.GA13560@redhat.com>
 <fcb7be01-38c1-ed1f-70a0-d03dc9260473@nvidia.com>
 <20190328165708.GH31324@iweiny-DESK2.sc.intel.com>
 <20190329010059.GB16680@redhat.com>
 <55dd8607-c91b-12ab-e6d7-adfe6d9cb5e2@nvidia.com>
 <20190329015003.GE16680@redhat.com>
 <20190328182100.GJ31324@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190328182100.GJ31324@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Fri, 29 Mar 2019 02:25:23 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 11:21:00AM -0700, Ira Weiny wrote:
> On Thu, Mar 28, 2019 at 09:50:03PM -0400, Jerome Glisse wrote:
> > On Thu, Mar 28, 2019 at 06:18:35PM -0700, John Hubbard wrote:
> > > On 3/28/19 6:00 PM, Jerome Glisse wrote:
> > > > On Thu, Mar 28, 2019 at 09:57:09AM -0700, Ira Weiny wrote:
> > > >> On Thu, Mar 28, 2019 at 05:39:26PM -0700, John Hubbard wrote:
> > > >>> On 3/28/19 2:21 PM, Jerome Glisse wrote:
> > > >>>> On Thu, Mar 28, 2019 at 01:43:13PM -0700, John Hubbard wrote:
> > > >>>>> On 3/28/19 12:11 PM, Jerome Glisse wrote:
> > > >>>>>> On Thu, Mar 28, 2019 at 04:07:20AM -0700, Ira Weiny wrote:
> > > >>>>>>> On Mon, Mar 25, 2019 at 10:40:02AM -0400, Jerome Glisse wrote:
> > > >>>>>>>> From: Jérôme Glisse <jglisse@redhat.com>
> > > >>> [...]
> > > >>>>>>>> @@ -67,14 +78,9 @@ struct hmm {
> > > >>>>>>>>   */
> > > >>>>>>>>  static struct hmm *hmm_register(struct mm_struct *mm)
> > > >>>>>>>>  {
> > > >>>>>>>> -	struct hmm *hmm = READ_ONCE(mm->hmm);
> > > >>>>>>>> +	struct hmm *hmm = mm_get_hmm(mm);
> > > >>>>>>>
> > > >>>>>>> FWIW: having hmm_register == "hmm get" is a bit confusing...
> > > >>>>>>
> > > >>>>>> The thing is that you want only one hmm struct per process and thus
> > > >>>>>> if there is already one and it is not being destroy then you want to
> > > >>>>>> reuse it.
> > > >>>>>>
> > > >>>>>> Also this is all internal to HMM code and so it should not confuse
> > > >>>>>> anyone.
> > > >>>>>>
> > > >>>>>
> > > >>>>> Well, it has repeatedly come up, and I'd claim that it is quite 
> > > >>>>> counter-intuitive. So if there is an easy way to make this internal 
> > > >>>>> HMM code clearer or better named, I would really love that to happen.
> > > >>>>>
> > > >>>>> And we shouldn't ever dismiss feedback based on "this is just internal
> > > >>>>> xxx subsystem code, no need for it to be as clear as other parts of the
> > > >>>>> kernel", right?
> > > >>>>
> > > >>>> Yes but i have not seen any better alternative that present code. If
> > > >>>> there is please submit patch.
> > > >>>>
> > > >>>
> > > >>> Ira, do you have any patch you're working on, or a more detailed suggestion there?
> > > >>> If not, then I might (later, as it's not urgent) propose a small cleanup patch 
> > > >>> I had in mind for the hmm_register code. But I don't want to duplicate effort 
> > > >>> if you're already thinking about it.
> > > >>
> > > >> No I don't have anything.
> > > >>
> > > >> I was just really digging into these this time around and I was about to
> > > >> comment on the lack of "get's" for some "puts" when I realized that
> > > >> "hmm_register" _was_ the get...
> > > >>
> > > >> :-(
> > > >>
> > > > 
> > > > The get is mm_get_hmm() were you get a reference on HMM from a mm struct.
> > > > John in previous posting complained about me naming that function hmm_get()
> > > > and thus in this version i renamed it to mm_get_hmm() as we are getting
> > > > a reference on hmm from a mm struct.
> > > 
> > > Well, that's not what I recommended, though. The actual conversation went like
> > > this [1]:
> > > 
> > > ---------------------------------------------------------------
> > > >> So for this, hmm_get() really ought to be symmetric with
> > > >> hmm_put(), by taking a struct hmm*. And the null check is
> > > >> not helping here, so let's just go with this smaller version:
> > > >>
> > > >> static inline struct hmm *hmm_get(struct hmm *hmm)
> > > >> {
> > > >>     if (kref_get_unless_zero(&hmm->kref))
> > > >>         return hmm;
> > > >>
> > > >>     return NULL;
> > > >> }
> > > >>
> > > >> ...and change the few callers accordingly.
> > > >>
> > > >
> > > > What about renaning hmm_get() to mm_get_hmm() instead ?
> > > >
> > > 
> > > For a get/put pair of functions, it would be ideal to pass
> > > the same argument type to each. It looks like we are passing
> > > around hmm*, and hmm retains a reference count on hmm->mm,
> > > so I think you have a choice of using either mm* or hmm* as
> > > the argument. I'm not sure that one is better than the other
> > > here, as the lifetimes appear to be linked pretty tightly.
> > > 
> > > Whichever one is used, I think it would be best to use it
> > > in both the _get() and _put() calls. 
> > > ---------------------------------------------------------------
> > > 
> > > Your response was to change the name to mm_get_hmm(), but that's not
> > > what I recommended.
> > 
> > Because i can not do that, hmm_put() can _only_ take hmm struct as
> > input while hmm_get() can _only_ get mm struct as input.
> > 
> > hmm_put() can only take hmm because the hmm we are un-referencing
> > might no longer be associated with any mm struct and thus i do not
> > have a mm struct to use.
> > 
> > hmm_get() can only get mm as input as we need to be careful when
> > accessing the hmm field within the mm struct and thus it is better
> > to have that code within a function than open coded and duplicated
> > all over the place.
> 
> The input value is not the problem.  The problem is in the naming.
> 
> obj = get_obj( various parameters );
> put_obj(obj);
> 
> 
> The problem is that the function is named hmm_register() either "gets" a
> reference to _or_ creates and gets a reference to the hmm object.
> 
> What John is probably ready to submit is something like.
> 
> struct hmm *get_create_hmm(struct mm *mm);
> void put_hmm(struct hmm *hmm);
> 
> 
> So when you are reading the code you see...
> 
> foo(...) {
> 	struct hmm *hmm = get_create_hmm(mm);
> 
> 	if (!hmm)
> 		error...
> 
> 	do stuff...
> 
> 	put_hmm(hmm);
> }
> 
> Here I can see a very clear get/put pair.  The name also shows that the hmm is
> created if need be as well as getting a reference.
> 

You only need to create HMM when you either register a mirror or
register a range. So they two pattern:

    average_foo() {
        struct hmm *hmm = mm_get_hmm(mm);
        ...
        hmm_put(hmm);
    }

    register_foo() {
        struct hmm *hmm = hmm_register(mm);
        ...
        return 0;
    error:
        ...
        hmm_put(hmm);
    }

Cheers,
Jérôme

