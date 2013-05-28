Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id ECA576B0070
	for <linux-mm@kvack.org>; Tue, 28 May 2013 16:08:40 -0400 (EDT)
Message-ID: <51A50EC4.4090108@ubuntu.com>
Date: Tue, 28 May 2013 16:08:36 -0400
From: Phillip Susi <psusi@ubuntu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v2 00/15][Sorted-buddy] mm: Memory Power Management
References: <20130409214443.4500.44168.stgit@srivatsabhat.in.ibm.com> <5170D781.3000102@gmail.com> <5170EE4F.9030908@linux.vnet.ibm.com>
In-Reply-To: <5170EE4F.9030908@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: Simon Jeons <simon.jeons@gmail.com>, akpm@linux-foundation.org, mgorman@suse.de, matthew.garrett@nebula.com, dave@sr71.net, rientjes@google.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, wujianguo@huawei.com, kmpark@infradead.org, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 4/19/2013 3:12 AM, Srivatsa S. Bhat wrote:
> But going further, as I had mentioned in my TODO list, we can be
> smarter than this while doing compaction to evacuate memory regions
> - we can choose to migrate only the active pages, and leave the
> inactive pages alone. Because, the goal is to actually consolidate
> the *references* and not necessarily the *allocations* themselves.

That would help with keeping references compact to allow use of the
low power states, but it would also be nice to keep allocations
compact, and completely power off a bank of ram with no allocations.


-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (MingW32)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBAgAGBQJRpQ7EAAoJEJrBOlT6nu75wqYH/Aq18xGwk3QCJPEBb3BQX4be
NY0JfHH9sHE7CFH4t13qpwNj/+N73xBg+TumY2qekUxqfwYSRo3hDhPRonlW/eDI
X2AaEGDs8+aQT+QY8bAZnZFHFX8ZayNYOsNCewEV8djZDll2l+fOaFjVfZAwuQLK
KtsMxjhlTzqMleRxVpZFLtVPG4GzLRITifKlBRQ+ffrO1zTTMI7glvM+IygIa5vS
ajOCI0Nis1Rst2cOsrxfWc+DKN+gnI6c/qTsHarPD5zda1AFwe9DzWQ7EGiqnbJq
39vJmGIsspwrEPbaK0VX5dVYp85Bvd03EudeEish4EHVmH+hphpFokxoypRJePg=
=Flf3
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
