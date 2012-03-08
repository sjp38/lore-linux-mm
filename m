Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 859336B002C
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 19:18:15 -0500 (EST)
Received: by eeke53 with SMTP id e53so2916244eek.14
        for <linux-mm@kvack.org>; Wed, 07 Mar 2012 16:18:14 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: decode GFP flags in oom killer output.
References: <20120307233939.GB5574@redhat.com>
 <1331165061.20565.19.camel@joe2Laptop>
Date: Thu, 08 Mar 2012 01:18:12 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.watsgmo13l0zgt@mpn-glaptop>
In-Reply-To: <1331165061.20565.19.camel@joe2Laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Joe Perches <joe@perches.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu, 08 Mar 2012 01:04:21 +0100, Joe Perches <joe@perches.com> wrote:=


> On Wed, 2012-03-07 at 18:39 -0500, Dave Jones wrote:
>> +static void decode_gfp_mask(gfp_t gfp_mask, char *out_string)
>> +{
>> +	unsigned int i;
>> +
>> +	for (i =3D 0; i < 32; i++) {
>
> < sizeof(gfp_t * 8)
>
>> +		if (gfp_mask & (1 << i)) {
>
> (gfp_t)1 << i
>
>> +			if (gfp_flag_texts[i])
>> +				out_string +=3D sprintf(out_string, "%s ", gfp_flag_texts[i]);
>> +			else
>> +				out_string +=3D sprintf(out_string, "reserved! ");
>
> 	not much use to exclamation points.
>
>> +		}
>> +	}
>> +	out_string =3D "\0";
>
> 	out_string[-1] =3D 0;

Will break if gfp_mask =3D=3D 0.

>> +}
>> +

-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz=
    (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
