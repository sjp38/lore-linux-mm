From: Andi Kleen <ak@suse.de>
Subject: Re: libnuma interleaving oddness
Date: Wed, 30 Aug 2006 20:12:57 +0200
References: <20060829231545.GY5195@us.ibm.com> <200608300932.23746.ak@suse.de> <eada2a070608301101j205b2711va5c287dbf8aab492@mail.gmail.com>
In-Reply-To: <eada2a070608301101j205b2711va5c287dbf8aab492@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200608302012.57592.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tim Pepper <tpepper@gmail.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

> On my list of random things to do is trying to improve the test
> coverage in this area.  We keep running into bugs or possible bugs or
> confusion on expected behaviour.  I'm going through the code trying to
> understand it and writing little programs to confirm my understanding
> here and there anyway.

numactl has a little regression test suite in test/* that tests a lot of stuff,
but not all. Feel free to extend it.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
