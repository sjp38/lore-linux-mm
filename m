Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBEE1C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 13:06:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62F4920684
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 13:06:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="cLak+fkR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62F4920684
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E91738E0003; Wed,  6 Mar 2019 08:06:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E190D8E0002; Wed,  6 Mar 2019 08:06:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CB9EB8E0003; Wed,  6 Mar 2019 08:06:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8664E8E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 08:06:28 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id 11so12243018pgd.19
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 05:06:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=lYFisdL+emxX/yjhRwvfei8UQc72RGGLjL/HzcIurDc=;
        b=B+BbdmhnLvDl8X2SP9scnzhl1PTOuDMltOVo4JfUL+qmt54Ri8Zqqn/pVFQ2pcrY/c
         dVGTi44eV4adAcALwN5DaZQ5G81fFuO7InTblmyo/uxMX33d5WORvNjHROH06al5jgqp
         IWCGVwq39G/eQ7GfpfgaVRB2IJ5HjG6DR+pCm9prvzhSTHvMN8HG/hrTpqOK/My+BrUK
         kT+UHFbjKJZbcdWHDfhpj9pcMQwfUESY422qQ/H5ggxRQ+26jMUmohuDRUKu4bYpXns9
         +mHkHmjrHOb54JEkd7Xh6xldcIUqfCvJ0ufULJPp9hXnocn0cozbL0clHVth8kLzjlF4
         K4Xw==
X-Gm-Message-State: APjAAAXlroZWk134zIjt9UdFLGqBiJru4gOgJvIUfx6+9u25Y20u2Tz5
	2SH7Ge5rMhX4NTp+AYC7S5tDrFyMA8kUF86zVAhJwedfuAdROPoJagPrd6D6Aw0aGuBA56rPnqY
	QvVK6iRyARHNPLkesz5IHxwOjPaQwCw4O9XdUrietfwGCJEkQg/AiFeTDwvH1/CKjPnPvYQckck
	5BPEdtKgOsAo82yIluKKkcBo+9Cx7Q8ZpgxIzLudyO1DJv8Hg12ZkiF3kfsT9AIDA3N6b12gB8+
	BalwVAsbzEip3cPavm0OL7JhSkN7pId0YRHiY/tDNq9s8doWz0lf8Pi7qaLa/fLCma4OWI2gOOa
	oCAeOwqhhCV2YmcXwjCf23/sBpqbk25MDJJ8GVPxMwXlOBywnVC9j71J7BRxWYyDXv89+AI9k6Y
	r
X-Received: by 2002:a17:902:6b81:: with SMTP id p1mr7019212plk.106.1551877588217;
        Wed, 06 Mar 2019 05:06:28 -0800 (PST)
X-Received: by 2002:a17:902:6b81:: with SMTP id p1mr7019114plk.106.1551877587198;
        Wed, 06 Mar 2019 05:06:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551877587; cv=none;
        d=google.com; s=arc-20160816;
        b=VlKWYGagp7v6UUlEpwnnd70fdPfXoGF/jI2HXf5tf1viVUfU+UaFouIlObI9m6/By6
         gN93iqkTpQ9+nHWbOt1CJ3N0rKbNr6h51wA804F1P+L7k5phOG/MVTtFVQTtuZ/toDiF
         M36NiOWKgn80Iz+n70sdqpq6abpqeRodytOIAfXYH5mDPYP33VAiqt4xcMkeslXjLFkn
         MABIc7/vgpoDzNt9k0AWIUSzuDhFjMCpucc5FC8DldQf9jqmP+GUTiqVKQcA0QAD7uDY
         mQwrgHtDJkMqCw4J+QrtKYsAbXpDxQg2KT30/c7XHtmS0vt8qezd5JM5jIi7X4Vkye7W
         rZQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=lYFisdL+emxX/yjhRwvfei8UQc72RGGLjL/HzcIurDc=;
        b=tvIdQPaiayqZqCPPtuFSU459DenUOYO+XScDcR+I2aWxmbbylszUylDL+p+oK7O7Bx
         +MqfwyJN1xJ76C1ofz3qJhcRMT7tz4fqMI1rvS+1V4WohsxqK9bGFP+7naoG7aiRI+1e
         i4XEgSf7QPOUECQ5x7DTVHG+39vGAUPQsohgo1Z4Upug1i7O8M1sh4Ig1BZhKvzWaD0C
         zQtCmS9CATOUdlTMOYRAsTqmpoHX8ZvfMox2zxa1LPCEThyuBMhuX96B8MhuDBSfTv3/
         0j7X2qrlYlTggXtCQMiNxaQMwZKu52brblMVfbTifPc2JyClySFi4zugRni5SPIqr+gc
         +/7g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=cLak+fkR;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m68sor2796093pfi.2.2019.03.06.05.06.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Mar 2019 05:06:27 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=cLak+fkR;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=lYFisdL+emxX/yjhRwvfei8UQc72RGGLjL/HzcIurDc=;
        b=cLak+fkRb0O9N36cRBXR0tIORoqVJxZ7ho2DOkLt9kahJGvAC87zHhp1EhS+FaCI6N
         64Nca7nkQJmc8Ta4Xu5NycVUDhC+r0AdMVUYL3w+51kWq9QtPbdBEF2WaGRHDv03lA3V
         0/b/Rf4n74LhnFC3Kksz+CwFlyn5hivfSwNhTuzAZU7m6SVWyix3v7rS4wyqjjZOlQuX
         zX1kyt/LbnnJgOYR9xb2o+9l5g/v3e371TkOhKxTCH3gTa3ftEUk55v9oRM+IqBC2dUn
         i9j2ihAYu03W9iivIo1u4bpyt44/sSHgVPZS+Sg9DcAbppyJSuoiEyGosF4XIvC4e9Zr
         KhEw==
X-Google-Smtp-Source: APXvYqzAzhlyQEbt3pF4RlErlixy++ggRJiOcUf8oHOCw2kVjZAxkP62zfdXeK2RBjhWPna+/sKHbg==
X-Received: by 2002:a62:4553:: with SMTP id s80mr7069624pfa.141.1551877586275;
        Wed, 06 Mar 2019 05:06:26 -0800 (PST)
Received: from kshutemo-mobl1.localdomain (fmdmzpr04-ext.fm.intel.com. [192.55.54.39])
        by smtp.gmail.com with ESMTPSA id h10sm3128992pfo.128.2019.03.06.05.06.25
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 05:06:25 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id 98357301186; Wed,  6 Mar 2019 16:06:21 +0300 (+03)
Date: Wed, 6 Mar 2019 16:06:21 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Michal =?utf-8?B?U3VjaMOhbmVr?= <msuchanek@suse.de>,
	Dan Williams <dan.j.williams@intel.com>, Oliver <oohall@gmail.com>,
	Jan Kara <jack@suse.cz>, linux-nvdimm@lists.01.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>, Ross Zwisler <zwisler@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 2/2] mm/dax: Don't enable huge dax mapping by default
Message-ID: <20190306130621.qrwybv5dpv3bzyym@kshutemo-mobl1>
References: <20190228083522.8189-1-aneesh.kumar@linux.ibm.com>
 <20190228083522.8189-2-aneesh.kumar@linux.ibm.com>
 <CAOSf1CHjkyX2NTex7dc1AEHXSDcWA_UGYX8NoSyHpb5s_RkwXQ@mail.gmail.com>
 <CAPcyv4jhEvijybSVsy+wmvgqfvyxfePQ3PUqy1hhmVmPtJTyqQ@mail.gmail.com>
 <87k1hc8iqa.fsf@linux.ibm.com>
 <20190306124453.126d36d8@naga.suse.cz>
 <df01bf6e-84a1-53fb-bf0c-0957af2f79e1@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <df01bf6e-84a1-53fb-bf0c-0957af2f79e1@linux.ibm.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 06, 2019 at 06:15:25PM +0530, Aneesh Kumar K.V wrote:
> On 3/6/19 5:14 PM, Michal Suchánek wrote:
> > On Wed, 06 Mar 2019 14:47:33 +0530
> > "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> wrote:
> > 
> > > Dan Williams <dan.j.williams@intel.com> writes:
> > > 
> > > > On Thu, Feb 28, 2019 at 1:40 AM Oliver <oohall@gmail.com> wrote:
> > > > > 
> > > > > On Thu, Feb 28, 2019 at 7:35 PM Aneesh Kumar K.V
> > > > > <aneesh.kumar@linux.ibm.com> wrote:
> > > Also even if the user decided to not use THP, by
> > > echo "never" > transparent_hugepage/enabled , we should continue to map
> > > dax fault using huge page on platforms that can support huge pages.
> > 
> > Is this a good idea?
> > 
> > This knob is there for a reason. In some situations having huge pages
> > can severely impact performance of the system (due to host-guest
> > interaction or whatever) and the ability to really turn off all THP
> > would be important in those cases, right?
> > 
> 
> My understanding was that is not true for dax pages? These are not regular
> memory that got allocated. They are allocated out of /dev/dax/ or
> /dev/pmem*. Do we have a reason not to use hugepages for mapping pages in
> that case?

Yes. Like when you don't want dax to compete for TLB with mission-critical
application (which uses hugetlb for instance).

-- 
 Kirill A. Shutemov

