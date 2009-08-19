Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 399D16B004D
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 23:31:42 -0400 (EDT)
Received: by an-out-0708.google.com with SMTP id c3so1624434ana.26
        for <linux-mm@kvack.org>; Tue, 18 Aug 2009 20:31:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1250633438.7335.1146.camel@nimitz>
References: <alpine.LFD.2.00.0908172333410.32114@casper.infradead.org>
	 <1250633438.7335.1146.camel@nimitz>
Date: Wed, 19 Aug 2009 15:31:39 +1200
Message-ID: <202cde0e0908182031r7068416amfb1cd48f4e91ddc4@mail.gmail.com>
Subject: Re: [PATCH 2/3]HTLB mapping for drivers. Hstate for files with
	hugetlb mapping(take 2)
From: Alexey Korolev <akorolex@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Alexey Korolev <akorolev@infradead.org>, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>> =C2=A0#ifdef CONFIG_HUGETLBFS
>> +
>> +/* some random number */
>> +#define HUGETLBFS_MAGIC =C2=A0 =C2=A0 =C2=A0 =C2=A00x958458f6
>
> Doesn't this belong in include/linux/magic.h?
>
> -- Dave
>
Right. Thank you! Will be corrected.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
