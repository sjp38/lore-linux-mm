Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 36C516B0292
	for <linux-mm@kvack.org>; Sat, 24 Jun 2017 02:15:59 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id f127so61325968pgc.10
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 23:15:59 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id 87si4742179pfk.133.2017.06.23.23.15.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 23:15:58 -0700 (PDT)
Subject: Re: [HMM 01/15] hmm: heterogeneous memory management documentation
References: <20170524172024.30810-1-jglisse@redhat.com>
 <20170524172024.30810-2-jglisse@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <3937c1fd-5ac9-a933-9562-98e728a22cfb@nvidia.com>
Date: Fri, 23 Jun 2017 23:15:56 -0700
MIME-Version: 1.0
In-Reply-To: <20170524172024.30810-2-jglisse@redhat.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Dan Williams <dan.j.williams@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On 05/24/2017 10:20 AM, J=C3=A9r=C3=B4me Glisse wrote:
> This add documentation for HMM (Heterogeneous Memory Management). It
> presents the motivation behind it, the features necessary for it to
> be useful and and gives an overview of how this is implemented.
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> ---
>   Documentation/vm/hmm.txt | 362 ++++++++++++++++++++++++++++++++++++++++=
+++++++
>   MAINTAINERS              |   7 +
>   2 files changed, 369 insertions(+)
>   create mode 100644 Documentation/vm/hmm.txt
>=20
> diff --git a/Documentation/vm/hmm.txt b/Documentation/vm/hmm.txt
> new file mode 100644
> index 0000000..a18ffc0
> --- /dev/null
> +++ b/Documentation/vm/hmm.txt
> @@ -0,0 +1,362 @@
> +Heterogeneous Memory Management (HMM)
> +

Some months ago, I made a rash promise to give this document some editing l=
ove. I am still=20
willing to do that if anyone sees the need, but I put it on the back burner=
 because I=20
suspect that the document is already good enough. This is based on not seei=
ng any "I am=20
having trouble understanding HMM" complaints.

If that's not the case, please speak up. Otherwise, I'm assuming that all i=
s well in the=20
HMM Documentation department.

thanks,
--
John Hubbard
NVIDIA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
