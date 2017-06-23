Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A84EE6B02C3
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 21:41:30 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id g7so31297272pgr.3
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 18:41:30 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id o28si2441094pli.603.2017.06.22.18.41.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 18:41:30 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id u62so4454254pgb.0
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 18:41:29 -0700 (PDT)
Date: Fri, 23 Jun 2017 09:41:26 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] docs/memory-hotplug: adjust the explanation of
 valid_zones sysfs
Message-ID: <20170623014126.GB14321@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170622041844.9852-1-richard.weiyang@gmail.com>
 <20170622182113.GC19563@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="p4qYPpj5QlsIQJ0K"
Content-Disposition: inline
In-Reply-To: <20170622182113.GC19563@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--p4qYPpj5QlsIQJ0K
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 22, 2017 at 08:21:14PM +0200, Michal Hocko wrote:
>On Thu 22-06-17 12:18:44, Wei Yang wrote:
>[...]
>> -'valid_zones'     : read-only: designed to show which zones this memory=
 block
>> -		    can be onlined to.
>> -		    The first column shows it's default zone.
>> +'valid_zones'     : read-only: shows different information based on sta=
te.
>> +		    When state is online, it is designed to show the
>> +		    zone name this memory block is onlined to.
>> +		    When state is offline, it is designed to show which zones
>> +		    this memory block can be onlined to.  The first column
>> +		    shows it's default zone.
>
>I do not think we really need to touch this. First of all the last
>sentence is not really correct. The ordering of zones doesn't tell which
>zone will be onlined by default. This is indeed a change of behavior of
>my patch. I am just not sure anybody depends on that. I can fix it up
>but again the old semantic was just awkward and I didn't feel like I
>should keep it. Also I plan to change this behavior again with planned
>patches. I would like to get rid of the non-overlapping zones
>restriction so the wording would have to change again.

Sure, look forward your up coming patches.

>
>That being said, let's keep the wording as it is now.
>
>Thanks!
>--=20
>Michal Hocko
>SUSE Labs

--=20
Wei Yang
Help you, Help me

--p4qYPpj5QlsIQJ0K
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZTHHGAAoJEKcLNpZP5cTdu6IQAIAZQ4jhz0Uqcc6bwwQtK7rI
LOkJCNCR3jFOfBG9cBYJgbvDNnoHyfqDR9exC5jMxVHVKDchUdrxSsYpiBsIZctp
Oe1Apgd6lJIocsEGXMg1KLnYXUGCP9VgOLtrJCEoWpU2KDNKu6wa+ICzf8dK3ERF
xidM6kkHmwYttetV8ERqjCEU3MwlJq6+el9bUvqDB/aNf0OAWNxuyswt+jmE11zG
ugicDJ6/AMZ6m1RTo6W08TIbPS6sdgmpiJmJbHVq+5tqIbN/AUcT/Du+Q91Nr9ny
+tpYsteWaq6GclU8uFeVjm9WH1uVLmEXBrAHbo8csvE4FolS86t6ljegS10UalXI
AsRNpMPH5m9HwE+HdgloMowJgYYlyd/f6ykRwYzxVY05MomngQ3li/QO0NtNtj/G
U3vdlsDs+YWNOzmhDDR4j7phJCtLePXHcGSanNilkMeO+h8ZqQXJdjDcY7dA3kJD
ebJ5sDFOy8kbLiAm5cSxR5vChOqkjSAiWj/RqCQYTUhRfI3fb/51nRgD0of0md5V
zEF18SYlvZHvWycKSUNRXxc7CHXUWnSYCgVnDwd6Kc0qeOWZmO5+3ValjVwSu6wb
a1PApfsCxzGoKMlZ24PZaxk3V1Q/zGezhK2GrH8QL3knXhat5eeIv9qUD5GtIH8+
z7vrwp7JljHA2dyW7tgV
=Sft6
-----END PGP SIGNATURE-----

--p4qYPpj5QlsIQJ0K--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
